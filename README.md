#Versatile and Lossless Conversion of NCBI GenBank Records

I've tested a handful Perl and Python scripts to retrieve annotations from GenBank flat files (.gbk, .gbff or .seq). However, accurate or lossless conversion by parsing GenBank flat files seems like a dream. A better option is to download gff files from ftp://ftp.ncbi.nlm.nih.gov/genomes/. But the gff collection is only available for a subset of refseq. In addition, some entries might be outdated or temporarily pulled off during curation.

Here is the official solution: parsing ASN.1 files instead of flat files using annotwriter from NCBI C++ toolkit. However, there is no precompiled binary for the 131 MB binary. See http://sourceforge.net/p/song/mailman/song-devel/thread/F7F0DD93-49BD-41B5-862C-2834B8F578A6@lbl.gov/

1. Install NCBI C++ Toolkit but compile only annotwriter. See http://www.ncbi.nlm.nih.gov/mailman/pipermail/cpp/2015q4/002738.html

        curl -O ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools++/CURRENT/ncbi_cxx--12_0_0.tar.gz
        tar zxvf ncbi_cxx--12_0_0.tar.gz
        cd ncbi_cxx--12_0_0
        ./configure --with-flat-makefile
        make -f Makefile.flat annotwriter.exe
        make install
        export PATH=$PATH:/ANY/DIR/ncbi_cxx--12_0_0/bin

2. Download Entrez Direct suite

        curl -O ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.zip
        unzip edirect.zip
        export PATH=$PATH:~/ANY/DIR/edirect

3. Download an ASN.1 file

        efetch -db nucleotide -id <gi> > <gi.asn>

4. Convert an ASN.1 file to gff3 file

        annotwriter -i <gi.asn> -format gff3 -full-annots -o <gi.gff>

Another solution which is highly versatile is by parsing INSDseq XML files. The steps described below use viral refseq as an example.

1. Retrieve all GI from viral.1.1.genomic.fna

        curl -O ftp://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
        gunzip viral.1.1.genomic.fna.gz
        grep ">" viral.1.1.genomic.fna | awk 'BEGIN {FS="|"} {print $2}' > viral.1.1.genomic.gi

2. Download Entrez Direct suite

        curl -O ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.zip
        unzip edirect.zip
        export PATH=$PATH:~/ANY/DIR/edirect
    
3. Download viral refseq in INSDseq XML format using a list of GI. 
    
    NCBI Website and Data Usage Policies and Disclaimers: Run retrieval scripts on weekends or between 9 pm and 5 am Eastern Time weekdays for any series of more than 100 requests.

        while read name; do
            efetch -db nucleotide -id $name -format gpc > $name.xml;
            sleep 1;
        done < viral.1.1.genomic.gi 

4. Install XMLStarlet (optional)

    on Ubuntu:
    
        sudo apt-get install xmlstarlet

    on RedHat/CentOS/Fedora:
    
        yum install xmlstarlet

    on Mac OSX:
    
        curl -O http://iweb.dl.sourceforge.net/project/xmlstar/xmlstarlet/1.6.1/xmlstarlet-1.6.1.tar.gz
        tar zxvf xmlstarlet-1.6.1.tar.gz
        cd xmlstarlet-1.6.1
        sudo ./configure
        sudo make
        sudo make install
    
5. View INSDseq XML structure (optional) - helps in coding a stylesheet. 10313991.xml is one of the fetched files.

        xmlstarlet el 10313991.xml

6. Parsing XML with a custom stylesheet, which is surprisingly easy to code.

        xsltproc --novalid insdseq2annotation.xsl 10313991.xml
