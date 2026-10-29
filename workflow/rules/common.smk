# import basic packages
from snakemake.utils import validate

# validate config file
validate(config, schema="../schemas/config.schema.yaml")

genome_version = f"{lookup(within=config, dpath="ref/species")}.{lookup(within=config, dpath="ref/build")}.{lookup(within=config, dpath="ref/release")}"
