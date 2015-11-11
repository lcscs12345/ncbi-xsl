#Versatile and Lossless Conversion of NCBI GenBank Records

I've tested a handful Perl and Python scripts to retrieve annotations from GenBank flat files (.gbk, .gbff or .seq). However, to obtain lossless conversion by parsing GenBank flat files is a dream. A better option is to download gff files from ftp://ftp.ncbi.nlm.nih.gov/genomes/. But the gff collection is incomplete and only available for some refseq. Also, some genome entries might be temporarily pulled off during curation.

So here is a step-by-step solution, using viral refseq as an example. The key thing is parsing INSDseq XML files instead of GenBank flat files.

Retrieve GI from viral.1.1.genomic.fna

    curl -O ftp://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
    gunzip viral.1.1.genomic.fna.gz
    grep ">" viral.1.1.genomic.fna | sed 's/|/\t/g' | awk '{print $2}' > viral.1.1.genomic.gi

Download Entrez Direct suite

    curl -O ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.zip
    unzip edirect.zip
    export PATH=$PATH:~/ANY/DIR/edirect
    
Download viral refseq in INSDseq XML format using a list of GI

    while read name; do
        efetch -db nucleotide -id $name -format gpc > $name.xml;
    done < viral.1.1.genomic.gi 

Install XMLStarlet (optional)

on Ubuntu:
    
    sudo apt-get install xmlstarlet

on RedHat/CentOS/Fedora:
    
    yum install xmlstarlet

on Mac OSX: requires Xcode installed to build XMLStarlet from source
    
    curl -O http://iweb.dl.sourceforge.net/project/xmlstar/xmlstarlet/1.6.1/xmlstarlet-1.6.1.tar.gz
    tar zxvf xmlstarlet-1.6.1.tar.gz
    cd xmlstarlet-1.6.1
    sudo ./configure
    sudo make
    sudo make install
    
View INSDseq XML structure (optional) - helps in coding a stylesheet. 10313991.xml is one of the fetched files

    xmlstarlet el 10313991.xml

Parsing XML with a custom stylesheet, which is surprisingly easy to code.

    xsltproc --novalid insdseq2bed.xsl 10313991.xml
