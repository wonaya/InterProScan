################## MultiStage build ######################

################## Core ######################

FROM busybox AS buildcore

MAINTAINER Jawon Song <jawon@tacc.utexas.edu>

ARG IPR=5
ENV IPR $IPR
ARG IPRSCAN=5.44-79.0
ENV IPRSCAN $IPRSCAN

RUN mkdir -p /tmp/interproscan/bin/blast/ncbi-blast-2.9.0+
RUN mkdir -p /tmp/interproscan/bin/interproscan

RUN wget -O /tmp/interproscan-core-$IPRSCAN.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz
RUN wget -O /tmp/interproscan-core-$IPRSCAN.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz.md5


WORKDIR /tmp

RUN md5sum -c interproscan-core-$IPRSCAN.tar.gz.md5

RUN  tar -pxvzf interproscan-core-$IPRSCAN.tar.gz \
    -C /tmp/interproscan --strip-components=1 \
    && rm -f interproscan-core-$IPRSCAN.tar.gz interproscan-core-$IPRSCAN.tar.gz.md5


# Workaround bin/blast/ncbi-blast-2.9.0+/rpsblast: error while loading shared
# libraries: libgnutls.so.28: cannot open shared object file: No such file or 
# directory
RUN wget -O /tmp/ncbi-blast-2.9.0+-x64-linux.tar.gz ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz
RUN tar xvf ncbi-blast-2.9.0+-x64-linux.tar.gz


# copy the new version to the binary folder
RUN cp /tmp/ncbi-blast-2.9.0+/bin/rpsblast /tmp/interproscan/bin/blast/ncbi-blast-2.9.0+/rpsblast

################## BASE IMAGE ######################

FROM ubuntu:18.04

MAINTAINER Jawon Song <jawon@tacc.utexas.edu>
LABEL  base_image="ubuntu:16.04" \
       software="interproscan" \
       software.version="5.44-79.0" \
       version="1" \
       about.summary="Scan sequences against the InterPro protein signature databases." \
       about.home="https://www.ebi.ac.uk/interpro/interproscan.html" \
       about.license="Apache-2.0" \
       about.license_file="https://github.com/ebi-pf-team/interproscan/blob/dev/LICENSE" \
       about.documentation="https://github.com/ebi-pf-team/interproscan/wiki" \
       about.tags="biology::nucleic, biology::protein, field::biology, field::biology:bioinformatics, interface::commandline, role::program,:biological-sequence" \
       extra.identifier.biotools="interproscan_5" \
       extra.binaries="interproscan.sh"

COPY --from=buildcore /tmp/interproscan /tmp/interproscan

RUN mkdir -p /tmp/interproscan/data
RUN mkdir -p /data

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        parallel \
        build-essential \
        pkg-config      \
        python3         \
        bzip2           \
	libdw1 \
        wget \
	nano \
        openjdk-11-jre \
        ca-certificates && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /tmp/interproscan

ENV PATH=$PATH:/tmp/interproscan/bin

ADD splitfasta.pl /usr/bin
ADD iprs_wrapper.sh /usr/bin
ADD cyverse_parse_ips_xml.pl /usr/bin


ENTRYPOINT ["/bin/bash", "iprs_wrapper.sh"]
##################### INSTALLATION END #####################
