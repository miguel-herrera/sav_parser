#! /usr/bin/perl -w

use strict;
use warnings;


my @files = glob( './' . '*.tar.gz' );

# Output header
print "Run ID,Read Type,Indexed,Cycles analysed,Lane,Tiles,% Q>=30,Yield>=Q30,Density,Density SD,Clusters PF,Clusters PF SD,Phasing,Prephasing,Reads PF (M),Perfect Reads (M),<=3 errors (M),Cycle errors rated,Aligned %,Error rate %,Error rate 35 cycle %,Error rate 75 cycle %,Error rate 100 cycle %,Aligned % SD,Error rate % SD,Error rate 35 cycle % SD,Error rate 75 cycle % SD,Error rate 100 cycle % SD,Intensity Cycle 1,% Intensity Cycle 20,Intensity Cycle 1 SD,% Intensity Cycle 20 SD\n";

for my $i (0..@files-1){
  my $file=$files[$i];
  my $run_id=$file;
  $run_id=~ s/\.\/|\.tar\.gz//g;
  print STDERR "[$i] Processing: $run_id\n";

  # Decompress file and process
  `mkdir -p $run_id && tar -zxvf $file -C $run_id`;
  `summary $run_id > out.csv`;
 
  open (IN, "<out.csv") || die "Cannot open out.txt";
  my $line="";
  my %lane_data=();
  $lane_data{'Run_ID'}=$run_id;
  for my $j (0..9){$line=<IN>;}  # Remove summary information

  # Load column headers
  $line=<IN>;
  chomp($line);
  $line=~s/\s+//g;
  
  my @line=split(/,/,$line);
  my %header=();
  for my $j (0..@line-1){
    $header{$line[$j]}=$j;
  }

  $line=<IN>; 
  # Load read 1 data
  while($line !~ /^Read 2/){
    my @tmp=();

    chomp($line);
    $line=~s/\s+//g;
    @line=split(/,/,$line);

    my $lane=$line[$header{'Lane'}];
    $lane_data{'R1'}{$lane}{'Tiles'}+=$line[$header{'Tiles'}];
    if ($line[$header{'Surface'}] eq '-'){
      $lane_data{'R1'}{$lane}{'%>Q30'}=$line[$header{'%>=Q30'}];
      $lane_data{'R1'}{$lane}{'Yield>Q30'}=$line[$header{'Yield'}];
      @tmp=split(/\+\/-/,$line[$header{'Density'}]);
      $lane_data{'R1'}{$lane}{'Density'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Density_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'ClusterPF'}]);
      $lane_data{'R1'}{$lane}{'Clusters_PF'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Clusters_PF_SD'}=$tmp[1];
      @tmp=split(/\//,$line[$header{'Phas/Prephas'}]);
      $lane_data{'R1'}{$lane}{'Phasing'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Prepashing'}=$tmp[1];
      $lane_data{'R1'}{$lane}{'Reads_PF'}=$line[$header{'ReadsPF'}];
    
      $lane_data{'R1'}{$lane}{'Cycle_Error'}=$line[$header{'CyclesError'}];
      @tmp=split(/\+\/-/,$line[$header{'Aligned'}]);
      $lane_data{'R1'}{$lane}{'%Aligned'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'%Aligned_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error'}]);
      $lane_data{'R1'}{$lane}{'Error'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Error_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(35)'}]);
      $lane_data{'R1'}{$lane}{'Error35'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Error35_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(75)'}]);
      $lane_data{'R1'}{$lane}{'Error75'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Error75_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(100)'}]);
      $lane_data{'R1'}{$lane}{'Error100'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Error100_SD'}=$tmp[1];
      
      @tmp=split(/\+\/-/,$line[$header{'IntensityC1'}]);
      $lane_data{'R1'}{$lane}{'Intensity_1'}=$tmp[0];
      $lane_data{'R1'}{$lane}{'Intensity_1_SD'}=$tmp[1];
    }

    $line=<IN>;

  }
  <IN>;
  $line=<IN>;

  # Load data for Read 2
  while($line !~ /^Extracted/){
    my @tmp=();

    chomp($line);
    $line=~s/\s+//g;
    @line=split(/,/,$line);

    my $lane=$line[$header{'Lane'}];
    $lane_data{'R2'}{$lane}{'Tiles'}+=$line[$header{'Tiles'}];
    if ($line[$header{'Surface'}] eq '-'){
      $lane_data{'R2'}{$lane}{'%>Q30'}=$line[$header{'%>=Q30'}];
      $lane_data{'R2'}{$lane}{'Yield>Q30'}=$line[$header{'Yield'}];
      @tmp=split(/\+\/-/,$line[$header{'Density'}]);
      $lane_data{'R2'}{$lane}{'Density'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Density_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'ClusterPF'}]);
      $lane_data{'R2'}{$lane}{'Clusters_PF'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Clusters_PF_SD'}=$tmp[1];
      @tmp=split(/\//,$line[$header{'Phas/Prephas'}]);
      $lane_data{'R2'}{$lane}{'Phasing'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Prepashing'}=$tmp[1];
      $lane_data{'R2'}{$lane}{'Reads_PF'}=$line[$header{'ReadsPF'}];
    
      $lane_data{'R2'}{$lane}{'Cycle_Error'}=$line[$header{'CyclesError'}];
      @tmp=split(/\+\/-/,$line[$header{'Aligned'}]);
      $lane_data{'R2'}{$lane}{'%Aligned'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'%Aligned_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error'}]);
      $lane_data{'R2'}{$lane}{'Error'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Error_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(35)'}]);
      $lane_data{'R2'}{$lane}{'Error35'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Error35_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(75)'}]);
      $lane_data{'R2'}{$lane}{'Error75'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Error75_SD'}=$tmp[1];
      @tmp=split(/\+\/-/,$line[$header{'Error(100)'}]);
      $lane_data{'R2'}{$lane}{'Error100'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Error100_SD'}=$tmp[1];
      
      @tmp=split(/\+\/-/,$line[$header{'IntensityC1'}]);
      $lane_data{'R2'}{$lane}{'Intensity_1'}=$tmp[0];
      $lane_data{'R2'}{$lane}{'Intensity_1_SD'}=$tmp[1];
    }

    $line=<IN>;

  }
  close (IN);
  
  # Pull cycle data from RunInfo.xlm
  `grep "Read Number" $run_id/RunInfo.xml > out.xml`;
  my %run_data=();
  open (IN,"<out.xml") || die "Cannot open out.xml";
  while ($line=<IN>){
    chomp($line);
    @line=split(/"/,$line);
    $run_data{"R$line[1]"}{'Cycles'}=$line[3]-1;
    
    if ($line[5] eq "N"){$run_data{"R$line[1]"}{'Indexed'}="FALSE"}
    else{$run_data{"R$line[1]"}{'Indexed'}="TRUE"}
  }
  close (IN);
 
  my @lanes=sort keys(%{$lane_data{'R1'}});
  for my $j (0..@lanes-1){
    print "$run_id,Read 1,$run_data{'R1'}{'Indexed'},$run_data{'R1'}{'Cycles'},$lanes[$j],$lane_data{'R1'}{$lanes[$j]}{'Tiles'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'%>Q30'},$lane_data{'R1'}{$lanes[$j]}{'Yield>Q30'},$lane_data{'R1'}{$lanes[$j]}{'Density'},$lane_data{'R1'}{$lanes[$j]}{'Density_SD'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'Clusters_PF'},$lane_data{'R1'}{$lanes[$j]}{'Clusters_PF_SD'},$lane_data{'R1'}{$lanes[$j]}{'Phasing'},$lane_data{'R1'}{$lanes[$j]}{'Prepashing'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'Reads_PF'},,,$lane_data{'R1'}{$lanes[$j]}{'Cycle_Error'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'%Aligned'},$lane_data{'R1'}{$lanes[$j]}{'Error'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'Error35'},$lane_data{'R1'}{$lanes[$j]}{'Error75'},$lane_data{'R1'}{$lanes[$j]}{'Error100'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'%Aligned_SD'},$lane_data{'R1'}{$lanes[$j]}{'Error_SD'},";      
    print "$lane_data{'R1'}{$lanes[$j]}{'Error35_SD'},$lane_data{'R1'}{$lanes[$j]}{'Error75_SD'},$lane_data{'R1'}{$lanes[$j]}{'Error100_SD'},";
    print "$lane_data{'R1'}{$lanes[$j]}{'Intensity_1'},,$lane_data{'R1'}{$lanes[$j]}{'Intensity_1_SD'},\n";
 
    print "$run_id,Read 2 (I),$run_data{'R2'}{'Indexed'},$run_data{'R2'}{'Cycles'},$lanes[$j],$lane_data{'R2'}{$lanes[$j]}{'Tiles'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'%>Q30'},$lane_data{'R2'}{$lanes[$j]}{'Yield>Q30'},$lane_data{'R2'}{$lanes[$j]}{'Density'},$lane_data{'R2'}{$lanes[$j]}{'Density_SD'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'Clusters_PF'},$lane_data{'R2'}{$lanes[$j]}{'Clusters_PF_SD'},$lane_data{'R2'}{$lanes[$j]}{'Phasing'},$lane_data{'R2'}{$lanes[$j]}{'Prepashing'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'Reads_PF'},,,$lane_data{'R2'}{$lanes[$j]}{'Cycle_Error'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'%Aligned'},$lane_data{'R2'}{$lanes[$j]}{'Error'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'Error35'},$lane_data{'R2'}{$lanes[$j]}{'Error75'},$lane_data{'R2'}{$lanes[$j]}{'Error100'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'%Aligned_SD'},$lane_data{'R2'}{$lanes[$j]}{'Error_SD'},";      
    print "$lane_data{'R2'}{$lanes[$j]}{'Error35_SD'},$lane_data{'R2'}{$lanes[$j]}{'Error75_SD'},$lane_data{'R2'}{$lanes[$j]}{'Error100_SD'},";
    print "$lane_data{'R2'}{$lanes[$j]}{'Intensity_1'},,$lane_data{'R2'}{$lanes[$j]}{'Intensity_1_SD'},\n";
  }

  # Cleanup intermediate files
  `rm -rf $run_id out.csv out.xml`;
}
