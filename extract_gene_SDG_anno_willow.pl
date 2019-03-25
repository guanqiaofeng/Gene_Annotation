### Extract genes in SDR ###
### Guanqiao Feng ###
### 2019.03.23 ###

# Input files:
#    1. SDR file in the format of "CHROMOSOME START_POS END_POS" <-- input from command line
#    2. GFF file
#    3. ortholog file
#    4. At annotation file

$SDR = @ARGV[0]; # SDR file in the format of "CHROMOSOME START_POS END_POS" <-- input from command line

open OUT, ">Willow_SDR_gene_anno_output.txt";
print OUT "Locus\tGene\tAt_ortholog\tAnnotation\n";

# S. purpurea pacbio v5.1 gene blast best hit in Arabidopsis Araport11 #
%PuAt = ();
open FH, "<Spur_v5.1_to_Ara11.txt";
while (<FH>)
{
    if (/^(\S+)\s+(\S+)/)
    {
	$pu = $1;
	$at = $2;
	$PuAt{$pu} = $at;
    }
}
close FH;

# Araport11 gene annotation #
%AtAnno = ();
open FH, "<Araport11_gene_anno.txt";
while (<FH>)
{
    $seq = $_;
    chomp $seq;
    if (/^(\S+)/)
    {
	$atname = $1;
	$AtAnno{$atname} = $seq;
    }
}
close FH;

# find boundary of SDR #
open FH, "<$SDR";
while (<FH>)
{
    if (/(\S+)\s+(\S+)\s+(\S+)/)
    {
	$chr = $1;
	$start = $2;
	$end = $3;
    }
}
close FH;

# identify genes located within the boundary; ouput its ortholog in Arabidopsis; and the Arabidopsis gene annotation #
open FH, "<Spurpurea94006v5.1.gene.gff3";
while (<FH>)
{
    if (/^(\S+)\s+\S+\s+gene\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+ID=([^.]+)/)
    {
	$gene_chr = $1;
	$gene_start = $2;
	$gene_end = $3;
	$gene = $4;
	if (($chr eq $gene_chr) && ((($gene_start>$start) && ($gene_end<$end)) || (($gene_start<$start) && ($gene_end>$start) && ($gene_end<$end)) || (($gene_end>$end) && ($gene_start<$end) && ($gene_start>$start)) || (($gene_start<$start) && ($gene_end>$end))))
	{
	    print OUT "$gene_chr:$gene_start\_$gene_end\t$gene\t$AtAnno{$PuAt{$gene}}\n";
	}
    }
}
close FH;
close OUT;
