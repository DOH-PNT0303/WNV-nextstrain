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
