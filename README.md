#Flexible and Lossless Conversion of NCBI GenBank Records

I've tested a handful Perl and Python scripts to retrieve annotations from GenBank flat files (.gbk, .gbff or .seq). However, to obtain lossless conversion by parsing GenBank flat files is a dream. A better option is to download gff files from ftp://ftp.ncbi.nlm.nih.gov/genomes/. But the gff collection is incomplete and only available for some refseq.

So here is a step-by-step solution, using viral refseq as an example. The key thing is parsing INSDseq XML files instead of GenBank flat files.

    #retrieve gi from viral.1.1.genomic.fna
    curl -O ftp://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
    gunzip viral.1.1.genomic.fna.gz
    grep ">" viral.1.1.genomic.fna | sed 's/|/\t/g' | awk '{print $2}' > viral.1.1.genomic.gi

    #download Entrez Direct suite
    curl -O ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.zip
    unzip edirect.zip
    export PATH=$PATH:~/ANY/DIR/edirect
    
    #download viral refseq in INSDseq XML format using a list of gi using efetch
    while read name; do
        efetch -db nucleotide -id $name -format gpc > $name.xml;
    done < viral.1.1.genomic.gi 

    #install xmlstarlet on Ubuntu
    sudo apt-get install xmlstarlet
    #on RedHat/CENTOS/Fedora
    yum install xmlstarlet
    #on Mac OSX. Requires Xcode installed to build xmlstarlet from source
    curl -O http://iweb.dl.sourceforge.net/project/xmlstar/xmlstarlet/1.6.1/xmlstarlet-1.6.1.tar.gz
    tar zxvf xmlstarlet-1.6.1.tar.gz
    cd xmlstarlet-1.6.1
    sudo ./configure
    sudo make
    sudo make install
    
    #view xml structure - helps in writing a stylesheet
    #10313991.xml is one of the fetched files
    xmlstarlet el 10313991.xml

    #parsing xml with a custom stylesheet, insdseq2bed.xsl
    #output annotation as bed format
    xsltproc --novalid insdseq2bed.xsl 10313991.xml
