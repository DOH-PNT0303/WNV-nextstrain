"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

REQUIRED INPUTS:

    metadata    = data/metadata.tsv
    sequences   = data/sequences.fasta
    reference   = ../shared/reference.fasta

OUTPUTS:

    prepared_sequences = results/prepared_sequences.fasta

This part of the workflow usually includes the following steps:

    - augur index
    - augur filter
    - augur align
    - augur mask

See Augur's usage docs for these commands for more details.
"""
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
        sequences = "data/sequences.fasta.zst",
        metadata = "data/metadata.tsv.zst"
    output:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv"
    shell:
        """
        zstd -d -c {input.sequences} > {output.sequences}
        zstd -d -c {input.metadata} > {output.metadata}
        """


rule add_authors:
    message:
        "Adding authors to {input.metadata} -> {output.metadata} by collecting info from ENTREZ"
    input:
        metadata = "results/metadata_filtered.tsv"
    output:
        metadata = "results/metadata.tsv"
    shell:
        """
        python ./scripts/add_authors.py {input.metadata} {output.metadata}
        """

rule create_colors:
    message:
        "Creating custom color scale in {output.colors}"
    input:
        metadata = "results/metadata_filtered.tsv"
    output:
        colors = "results/colors.tsv"
    shell:
        """
        python ./scripts/make_colors.py {input.metadata} {output.colors}
        """

rule create_lat_longs:
    message:
        "Creating lat/longs in {output.lat_longs}"
    input:
        metadata = "results/metadata_filtered.tsv"
    output:
        lat_longs = "results/lat_longs.tsv"
    shell:
        """
        python ./scripts/create_lat_longs.py {input.metadata} {output.lat_longs}
        """

rule align:
    message:
        """
        Aligning sequences to {input.reference}
          - filling gaps with N
        """
    input:
        sequences = "results/sequences_filtered.fasta",
        reference = files.reference
    output:
        alignment = "results/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --output {output.alignment} \
            --fill-gaps \
            --reference-sequence {input.reference}
        """
