#Flexible and Lossless Conversion of NCBI GenBank Records

I've tested a handful Perl and Python scripts to retrieve annotations from GenBank flat files (.gbk, .gbff or .seq). However, to obtain lossless conversion by parsing GenBank flat files is a dream. A better option is to download gff files from ftp://ftp.ncbi.nlm.nih.gov/genomes/. But the gff collection is incomplete and only available for some refseq.

So here is the step-by-step solution, using viral refseq as an example. The key thing is parsing INSDseq XML files instead of GenBank flat files.

    #retrieve gi from viral.1.1.genomic.fna
    curl -O ftp://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
    gunzip viral.1.1.genomic.fna.gz
    grep ">" viral.1.1.genomic.fna | sed 's/|/\t/g' | awk '{print $2}' > viral.1.1.genomic.gi

    #download viral refseq in INSDseq XML format using a list of gi
    while read name; do
        efetch -db nucleotide -id $name -format gpc > $name.xml;
    done < viral.1.1.genomic.gi 

    #view xml structure - helps in writing a stylesheet
    #10313991.xml is one of the fetched files
    xmlstarlet el 10313991.xml

    #parsing xml with a custom stylesheet, insdseq2bed.xsl
    #output annotation as bed format
    xsltproc --novalid insdseq2bed.xsl 10313991.xml
