"""
This part of the workflow subsamples sequences for constructing the phylogenetic tree.

However, this configurable subsampling allows for tierred subsampling based on values placed in the config file.

REQUIRED INPUTS:

    metadata    = data/metadata.tsv
    sequences   = data/sequences.fasta

OUTPUTS:

    metadata_subsampled = results/metadata_filtered.tsv
    sequences_subsampled = results/sequences_filtered.fasta

This part of the workflow usually includes one or more of the following steps:

    - augur filter

See Augur's usage docs for these commands for more details.
"""
ruleorder: extract_subsampled_sequences_and_metadata > filter_manual

rule download:
    """Downloading sequences and metadata from s3 bucket"""
    output:
        sequences = "data/sequences_all.fasta.zst",
        metadata = "data/metadata_all.tsv.zst"
    params:
        sequences_url = "s3://wamep-nextstrain-jobs/workflows/wnv/sequences.fasta.zst",
        metadata_url = "s3://wamep-nextstrain-jobs/workflows/wnv/metadata.tsv.zst"
    shell:
        """
        aws s3 cp \
        {params.sequences_url:q} \
        {output.sequences}

        aws s3 cp \
        {params.metadata_url:q} \
        {output.metadata}
        """

rule decompress:
    """Decompressing sequences and metadata"""
    input:
        sequences = "data/sequences_all.fasta.zst",
        metadata = "data/metadata_all.tsv.zst"
    output:
        sequences = "data/sequences_all.fasta",
        metadata = "data/metadata_all.tsv"
    shell:
        """
        zstd -d -c {input.sequences} > {output.sequences}
        zstd -d -c {input.metadata} > {output.metadata}
        """

rule subsample:
    input:
        metadata = "data/metadata_all.tsv",
        sequences = "data/sequences_all.fasta"
    output:
        subsampled_strains = "results/subsampled_strains_{subsample}.txt",
    params:
        filters = lambda wildcards: config.get("subsampling", {}).get(wildcards.subsample, ""),
        id_column = config["strain_id_field"],
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.id_column} \
            {params.filters} \
            --output-strains {output.subsampled_strains}
        """

rule extract_subsampled_sequences_and_metadata:
    input:
        sequences = "data/sequences_all.fasta",
        metadata = "data/metadata_all.tsv",
        subsampled_strains = expand("results/subsampled_strains_{subsample}.txt", subsample=list(config.get("subsampling", {}).keys()))
    output:
        #sequences = "results/subsampled_sequences.fasta",
        #metadata = "results/subsampled_metadata.tsv",
        sequences = "results/sequences_filtered.fasta",
        metadata = "results/metadata_filtered.tsv",
    params:
        id_column = config["strain_id_field"],
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.id_column} \
            --exclude-all \
            --include {input.subsampled_strains} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata}
        """
