rule download_cds_fasta_gzipped:
    output:
        "resources/genome.all_cds.{genome}.fa.gz",
    log:
        "<logs>/download_cds_fasta_gzipped.{genome}.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    localrule: True
    params:
        species=lookup(within=config, dpath="ref/species"),
        datatype="cds",
        build=lookup(within=config, dpath="ref/build"),
        release=lookup(within=config, dpath="ref/release"),
    wrapper:
        "v7.3.0/bio/reference/ensembl-sequence"


rule get_canonical_transcript_ids_with_mane_select_annotation:
    output:
        table="resources/genome.canonical_transcript_ids_with_mane_select_annotation.{genome}.tsv",  # .gz extension is optional, but recommended
    log:
        "logs/genome.canonical_transcript_ids_with_mane_select_annotation.{genome}.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    localrule: True
    params:
        biomart="genes",
        species=lookup(within=config, dpath="ref/species"),
        build=lookup(within=config, dpath="ref/build"),
        release=lookup(within=config, dpath="ref/release"),
        attributes=[
            "ensembl_transcript_id",
            "transcript_mane_select",
        ],
        filters={"transcript_is_canonical": True},  # optional: restrict output by using filters
    wrapper:
        "v9.19.1/bio/reference/ensembl-biomart-table"


rule filter_canonical_to_mane_select:
    input:
        canonical="resources/genome.canonical_transcript_ids_with_mane_select_annotation.{genome}.tsv",  # .gz extension is optional, but recommended
    output:
        mane_select="resources/genome.mane_select.{genome}.tsv",  # .gz extension is optional, but recommended
    log:
        "logs/genome.mane_select.{genome}.tsv",
    localrule: True
    threads: 2
    params:
        extra="filter '$transcript_mane_select != \"\"' ",
    wrapper:
        "v9.18.1/utils/miller"


rule extract_id_column_from_tsv:
    input:
        tsv="resources/{tsv_path}.tsv",
    output:
        seqkit_pattern_file="resources/{tsv_path}.{id_column}.tsv",
    log:
        "logs/{tsv_path}.{id_column}.log",
    localrule: True
    threads: 2
    params:
        extra=lambda wc: f"--headerless-tsv-output cut -f {wc.id_column}",
    wrapper:
        "v9.18.1/utils/miller"


rule filter_cds_to_mane_select:
    input:
        mane_select_ensembl_ids="resources/genome.mane_select.{genome}.ensembl_transcript_id.tsv",
        cds="resources/genome.all_cds.{genome}.fa.gz",
    output:
        cds="resources/genome.mane_select_cds.{genome}.all.fa.gz",
    log:
        "logs/genome.filter_cds_to_mane_select.{genome}.log",
    conda:
        "../envs/seqkit.yaml"
    shell:
        "( seqkit grep --by-name --use-regexp --pattern-file {input.mane_select_ensembl_ids} {input.cds} -o {output.cds}"
        ") >{log} 2>&1"


rule download_ribosomal_gene_tables:
    output:
        s_genes="resources/gene_lists/small_ribosomal_subunit_genes.tsv",
        l_genes="resources/gene_lists/large_ribosomal_subunit_genes.tsv",
    log:
        "logs/download_ribosomal_gene_tables.log",
    localrule: True
    conda:
        "../envs/curl.yaml"
    shell:
        "( curl -o {output.s_genes} 'https://www.genenames.org/cgi-bin/genegroup/download?id=728&type=node'; "
        "  curl -o {output.l_genes} 'https://www.genenames.org/cgi-bin/genegroup/download?id=729&type=node'; "
        ") >{log} 2>&1"


rule concatenate_ribosomal_gene_tables:
    input:
        s_genes="resources/gene_lists/small_ribosomal_subunit_genes.tsv",
        l_genes="resources/gene_lists/large_ribosomal_subunit_genes.tsv",
    output:
        all_genes="resources/gene_lists/all_ribosomal_subunit_genes.tsv",
    log:
        "logs/concatenate_ribosomal_gene_tables.log",
    localrule: True
    threads: 2
    params:
        extra="cat then rename 'HGNC ID',hgnc_id",
    wrapper:
        "v9.18.1/utils/miller"


rule hgnc_id_to_seqkit_grep_pattern:
    input:
        hgnc_ids="resources/gene_lists/all_ribosomal_subunit_genes.hgnc_id.tsv",
    output:
        hgnc_ids="resources/gene_lists/all_ribosomal_subunit_genes.hgnc_id.seqkit_grep_pattern.tsv",
    log:
        "logs/all_ribosomal_subunit_genes.hgnc_id_to_seqkit_grep_pattern.log",
    localrule: True
    threads: 1
    params:
        expr="s/^\(.*\)$/Acc:\\1]/",
        extra="",
    wrapper:
        "v9.8.0/utils/sed"


rule filter_mane_select_cds_to_hgnc_ids:
    input:
        hgnc_ids="resources/gene_lists/{subset}.hgnc_id.seqkit_grep_pattern.tsv",
        cds="resources/genome.mane_select_cds.{genome}.all.fa.gz",
    output:
        filtered_cds="resources/genome.mane_select_cds.{genome}.{subset}.fa.gz",
    log:
        "logs/filter_mane_select_cds.{genome}.{subset}.tsv",
    conda:
        "../envs/seqkit.yaml"
    threads: 2
    shell:
        "( seqkit grep --by-name --use-regexp --pattern-file {input.hgnc_ids} {input.cds} -o {output.filtered_cds}"
        ") >{log} 2>&1"


rule calculate_rscu_across_ref_genome:
    input:
        fa_gz="resources/genome.mane_select_cds.{genome}.{subset}.fa.gz",
    output:
        rscu="resources/genome.mane_select_cds.{genome}.{subset}.rscu.tsv",
    log:
        "logs/calculate_rscu_across.mane_select_cds.{genome}.{subset}.rscu.log",
    localrule: True
    conda:
        "../envs/rscu.yaml"
    resources:
        mem_mb=16000,
    script:
        "../scripts/calculate_rscu_across_ref_genome.R"
