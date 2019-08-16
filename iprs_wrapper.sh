#!/usr/bin/bash
#######################################################################################################
##SET UP OPTIONS

while getopts a:b:B:cC:d:D:ef:F:ghi:lm:M:n:o:pr:R:t:T:vx:y: option
do
        case "${option}"
        in

                a) appl=${OPTARG};;
                b) outfilebase=${OPTARG};;
		B) badseq=${OPTARG};;
 		c) disableprecalc=true ;;
		C) cpus=${OPTARG};;
                d) outdir=${OPTARG};;
		D) db=${OPTARG};;
		e) disresanno=true ;;
                f) outformats=${OPTARG};;
		F) iprsoutdir=${OPTARG};;
                g) goterms=true ;;
		h) help=true ;;
		i) inputpath=${OPTARG};;
		l) lookup=true ;;
		m) minsize=${OPTARG};;
		M) mapfile=${OPTARG};;
		n) biocurator=${OPTARG};;
		o) outfilename=${OPTARG};;
		p) pathways=true ;;
		r) mode=${OPTARG};;
		R) crid=${OPTARG};;
		t) seqtype=${OPTARG} ;;
		T) tempdir=${OPTARG};;
		v) version=true;;
		x) taxon=${OPTARG};;
		y) type=${OPTARG};;
        esac
done
#####################################################################################################
if [[ "$help" = "true" ]] ; then
  echo "Options:
 -a  <ANALYSES>			            Optional, comma separated list of analyses.  If this option
                                            is not set, ALL analyses will be run.

 -b, <OUTPUT-FILE-BASE>   		    Optional, base output filename (relative or absolute path).
                                            Note that this option, the output directory (-d) option and
                                            the output file name (-o) option are mutually exclusive.  The
                                            appropriate file extension for the output format(s) will be
                                            appended automatically. By default the input file
                                            path/name will be used.

 -d,<OUTPUT-DIR>              		    Optional, output directory. Note that this option, the
                                            output file name (-o) option and the output file base (-b) option
                                            are mutually exclusive. The output filename(s) are the
                                            same as the input filename, with the appropriate file
                                            extension(s) for the output format(s) appended automatically .

 -c		                            Optional.  Disables use of the precalculated match lookup
                                            service.  All match calculations will be run locally.

 -C					    Optional. Supply the number of cpus to use.

 -e               			    Optional, excludes sites from the XML, JSON output

 -f <OUTPUT-FORMATS>             	    Optional, case-insensitive, comma separated list of output
                                            formats. Supported formats are TSV, XML, JSON, GFF3, HTML and
                                            SVG. Default for protein sequences are TSV, XML and
                                            GFF3, or for nucleotide sequences GFF3 and XML.

 -g		                            Optional, switch on lookup of corresponding Gene Ontology
                                            annotation (IMPLIES -l lookup option)

 -h	                                    Optional, display help information

 -i <INPUT-FILE-PATH>               	    Optional, path to fasta file that should be loaded on
                                            Master startup. Alternatively, in CONVERT mode, the
                                            InterProScan 5 XML file to convert.

 -l                     		    Also include lookup of corresponding InterPro
                                            annotation in the TSV and GFF3 output formats.

 -m <MINIMUM-SIZE>               	    Optional, minimum nucleotide size of ORF to report. Will
                                            only be considered if n is specified as a sequence type.
                                            Please be aware of the fact that if you specify a too
                                            short value it might be that the analysis takes a very long
                                            time!

 -o <EXPLICIT_OUTPUT_FILENAME>    	    Optional explicit output file name (relative or absolute
                                            path).  Note that this option, the output directory -d option
                                            and the output file basename -b option are mutually
                                            exclusive. If this option is given, you MUST specify a
                                            single output format using the -f option.  The output file
                                            name will not be modified. Note that specifying an output
                                            file name using this option OVERWRITES ANY EXISTING FILE.

 -p                             	    Optional, switch on lookup of corresponding Pathway
                                            annotation (IMPLIES -l lookup option)
 -t <SEQUENCE-TYPE>              	    Optional, the type of the input sequences (dna/rna (n)
                                            or protein (p)).  The default sequence type is protein.

 -T <TEMP-DIR>                  	    Optional, specify temporary file directory (relative or
                                            absolute path). The default location is temp/.

 -v                       		    Optional, display version number

Available analyses:
                      TIGRFAM (XX.X) : TIGRFAMs are protein families based on Hidden Markov Models or HMMs
                         SFLD (X.X) : SFLDs are protein families based on Hidden Markov Models or HMMs
                        ProDom (XXXX.X) : ProDom is a comprehensive set of protein domain families automatically generated from the UniProt Knowledge Database.
                        Hamap (XXXXXX.XX) : High-quality Automated and Manual Annotation of Microbial Proteomes
                        SMART (X.X) : SMART allows the identification and analysis of domain architectures based on Hidden Markov Models or HMMs
                          CDD (X.XX) : Prediction of CDD domains in Proteins
              ProSiteProfiles (XX.XXX) : PROSITE consists of documentation entries describing protein domains, families and functional sites as well as associated patterns and profiles to identify them
              ProSitePatterns (XX.XXX) : PROSITE consists of documentation entries describing protein domains, families and functional sites as well as associated patterns and profiles to identify them
                  SUPERFAMILY (X.XX) : SUPERFAMILY is a database of structural and functional annotation for all proteins and genomes.
                       PRINTS (XX.X) : A fingerprint is a group of conserved motifs used to characterise a protein family
                      PANTHER (X.X) : The PANTHER (Protein ANalysis THrough Evolutionary Relationships) Classification System is a unique resource that classifies genes by their functions, using published scientific experimental evidence and evolutionary relationships to predict function even in the absence of direct experimental evidence.
                       Gene3D (X.X.X) : Structural assignment for whole genes and genomes using the CATH domain structure database
                        PIRSF (X.XX) : The PIRSF concept is being used as a guiding principle to provide comprehensive and non-overlapping clustering of UniProtKB sequences into a hierarchical order to reflect their evolutionary relationships.
                         Pfam (XX.X) : A large collection of protein families, each represented by multiple sequence alignments and hidden Markov models (HMMs)
                        Coils (X.X) : Prediction of Coiled Coil Regions in Proteins
                   MobiDBLite (X.X) : Prediction of disordered domains Regions in Proteins

OPTIONS FOR XML PARSER OUTPUTS

-F <IPRS output directory> 		This is the output directory from InterProScan.
-D <database>				Supply the database responsible for these annotations.
-x <taxon>				NCBI taxon ID of the ID being annotated
-y <type>				Transcript or protein
-n <biocurator>				Name of the biocurator who made these annotations
-M <mapping file>			Optional. Mapping file.
-B <bad seq file>			Optional. Bad input sequence file." 				
  exit 0
fi
#####################################################################################################

ARGS=''

#IF STATEMENTS EXIST FOR EACH PARAMETER
if [ -n "${appl}" ]; then ARGS="$ARGS -appl $appl"; fi
if [ -n "${outfilebase}" ]; then ARGS="$ARGS -b $outfilebase"; fi
if [ -n "${outdir}" ]; then ARGS="$ARGS -d $outdir"; fi
if [ -n "${outformats}" ]; then ARGS="$ARGS -f $outformats"; fi
#if [ -n "${inputpath}" ]; then ARGS="$ARGS -i $inputpath"; fi
if [ -n "${minsize}" ]; then ARGS="$ARGS -ms $minsize"; fi
if [ -n "${outfilename}" ]; then ARGS="$ARGS -o $outfilename"; fi
if [ -n "${seqtype}" ]; then ARGS="$ARGS -t $seqtype"; fi
if [ -n "${tempdir}" ]; then ARGS="$ARGS -T $tempdir"; fi
if [ -n "${cpus}" ]; then ARGS="$ARGS --cpu $cpus"; fi
if [ -n "${mode}" ]; then ARGS="$ARGS --mode $mode"; fi
if [ -n "${crid}" ]; then ARGS="$ARGS --crid $crid"; fi
if [[ "$disableprecalc" = "true" ]]; then ARGS="$ARGS -c"; fi
if [[ "$disresanno" = "true" ]]; then ARGS="$ARGS -dra"; fi
if [[ "$goterms" = "true" ]]; then ARGS="$ARGS -goterms"; fi
if [[ "$help" = "true" ]]; then ARGS="$ARGS -help"; fi
if [[ "$lookup" = "true" ]]; then ARGS="$ARGS -iprlookup"; fi
if [[ "$pathways" = "true" ]]; then ARGS="$ARGS -pa"; fi
if [[ "$version" = "true" ]]; then ARGS="$ARGS -version"; fi

######################################################################################################
##REMOVE * - _ and . FROM SEQS
sed 's/\*//g' $inputpath > inputnostar.fasta
sed -i 's/\-//g' inputnostar.fasta 
sed -i  's/\_//g' inputnostar.fasta
sed -i 's/\.//g' inputnostar.fasta


##SPLIT FASTA INTO BLOCKS OF 1000?

/usr/bin/splitfasta.pl -f inputnostar.fasta -s query -o ./split -r 1000

##RUN IPRS
if [ ! -d ./$outdir ]; then mkdir $outdir; fi

parallel -j 0 /opt/interproscan/interproscan.sh -i {} -d $outdir $ARGS ::: ./split/query*


##MERGE SPLIT OUTPUTS
##REMOVE HEADERS?
##HOW MANY OUTPUT FORMATS ARE THERE?  TSV, XML, JSON, GFF3, HTML and SVG
#cat ./split/query*.tsv > $outdir/$inputpath.tsv
#cat ./split/query*.xml > $outdir/$inputpath.xml
#cat ./split/query*.json > $outdir/$inputpath.json
#cat ./split/query*.gff3 > $outdir/$inputpath.gff3
#cat ./split/query*.html > $outdir/$inputpath.html
#cat ./split/query*.svg > $outdir/$inputpath.svg

##PARSE XML

#cyverse_parse_ips_xml.pl -f $outdir -d $db -t $taxon -n $biocurator -y $type

##REMOVE TEMP FILES
#rm -r /temp
#rm inputnostar.fasta

