### Extract genes with High Fst ###
### Guanqiao Feng ###
### 2019.03.23 ###

# Input files:
#    1. Fst file in the format of "CHROMOSOME POS" --> input from command line
#    2. GFF file
#    3. ortholog file
#    4. At annotation file

$FST = @ARGV[0]; # Fst file in the format of "CHROMOSOME POS" --> input from command line 

open OUT, ">Willow_Fst_gene_anno_output.txt";
print OUT "Locus\tGene\tAt_ortholog\tAnnotation\tFst";

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

# find positions of Fst #
%Fst = ();
$n = 0;
open FH, "<$FST";
while (<FH>)
{
    $n = $n + 1;
    if (/(\S+)\s+(\S+)/)
    {
	$chr = $1;
	$pos = $2;
	$Fst{$n} = $chr . "," . $pos;
    }
}
close FH;

# identify genes contains high Fst; ouput its ortholog in Arabidopsis; and the Arabidopsis gene annotation #
%genelist = ();
open FH, "<Spurpurea94006v5.1.gene.gff3";
while (<FH>)
{
    if (/^(\S+)\s+\S+\s+gene\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+ID=([^.]+)/)
    {
	$gene_chr = $1;
	$gene_start = $2;
	$gene_end = $3;
	$gene = $4;
	for (1..$n)
	{
	    $i = $_;
	    $eachfst = $Fst{$i};
	    @eachfsts = split(/,/,$eachfst);
	    $fstchr = $eachfsts[0];
	    $fstpos = $eachfsts[1];
            if (($fstchr eq $gene_chr) && ($gene_start<=$fstpos) && ($gene_end>=$fstpos))
            {
                if (exists ($genelist{$gene}))
                {
                    print OUT ";$fstpos";
                }
                else
                {
                    if (exists ($PuAt{$gene}))
                    {
                        print OUT "\n$gene_chr:$gene_start\_$gene_end\t$gene\t$AtAnno{$PuAt{$gene}}\t$fstpos";
                        $genelist{$gene} = 0;
                    }
                    else
                    {
                        print OUT "\n$gene_chr:$gene_start\_$gene_end\t$gene\tNA\tNA\t$fstpos";
                    }
                }
            }

	}
    }
}
print OUT "\n";
close FH;
close OUT;
