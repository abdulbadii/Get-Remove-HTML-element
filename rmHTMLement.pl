#!/usr/bin/perl -w
use strict;

sub getNthEAtt {		# $_[0] searched el  $_[1]=nth or backw  $_[2] whole el under which to search  $_[4] nth backward
	if ($_[4]) {
		my $c=1;			# obtain max nth +1 to solve backward nth
		$_[2]=~/^<[a-z]\w*[^>]*+>(?:(?'cnt'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>|(?'node'<(\w++)[^>]*+>(?&cnt)*+<\/\g-1>)))*?(?=<$_[0]\b)(?&node)(?{ ++$c }))+/;
		$_[1]=$c-$_[4]}
	return not $_[2] =~/^(<[a-z]\w*[^>]*+>(?:(?'cnt'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>|(?'node'<(\w++)[^>]*+>(?&cnt)*+<\/\g-1>)))*?(?=<$_[0]\b)((?&node))){$_[1]})(?{ @{$_[3]}=[substr($1,0,-length($5)), $5] })/
}

sub getAllNthEAtt {		# $_[1] el under which to search  $_[2] its offset  $_[4]) nth range pos  $_[5]) attr
	my ($a,$b,$i,$pre)= (1, '*');
	if ($_[4]) {
		my ($lt,$e,$n)= $_[4]=~ /(?>(<)|>)(=)?(\d+)/;
		$b = $lt?	$e? "{$n}" : '{'.--$n.'}'	: ($a=$e? $n : $n+1, $b);
	}
	return not $_[1] =~/^(<[a-z]\w*[^>]*+>) (?:
	((?'cnt'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>|(?'node'<(\w++)[^>]*+>(?&cnt)*+<\/\g-1>)))*?)
	(?=<$_[0]\b$_[5])((?&node)) (?{
	if (++$i>=$a) {
		push (@{$_[3]}, [$_[2].$1.($pre.=$2), $6]); $pre.=$6}
	}) ) $b /x
}

sub getAllDepth {		# $_[1] nth/nth bckwrd  $_[2] search space ele $_[4] its offset $_[5] depth  $_[6] nth bckwrd
	my ($ret, $min, $max, $E, $onref, $d, @nd,$offset,$offs) = ($_[3], $_[5]);
	my @curNode=[$_[4], $_[2]];
	while (@curNode) {
		for $onref (@curNode) {
			if ($_[6]) { my $c=1;
				$onref->[1]=~/^<[a-z]\w*[^>]*+>(?:(?'cnt'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>|(?'node'<(\w++)[^>]*+>(?&cnt)*+<\/\g-1>)))*?(?=<$_[0]\b)(?&node)(?{ ++$c }))+/;
				$_[1]=$c-$_[6]
			}
			$onref->[1]=~
			/^(<[a-z]\w*[^>]*+>)(?{$offset=$1})
			(?'cnt'(?:
			((?'at'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>))*+)
			(?{$offs=$offset.=$3})
			(?:(?!<$_[0]\b)	(?{ $max=0 })
			(?'node'<(\w++)[^>]*+>
			(?{$max=$d if ++$d>$max})
			(?>(?&at)|(?&node))*+<\/\g-1>(?{--$d}))
			(?{if ($max>$min) {
				push (@nd, [$onref->[0].$offset, $+{node}]);
				$offset.=$+{node}}})
			)?)*+
			(?=<$_[0]\b)(?'tnd'(?{$max=0})(?&node))
			(?{ push (@nd, [$onref->[0].$offs, $+{tnd}]) if $max>$min;
			$offset=$offs.$+{tnd} })
			){$_[1]}
			(?{ push (@$ret, [$onref->[0].$offs, $+{tnd}]) if $max>=$min })
			(?&cnt)*/x
		}
		@curNode=@nd; @nd=();
	}
}
sub getAllDepNthRnAtt	{				# on every nth or positoned within range 
	my ($ret, $min, $att, $max, $E, $onref, $d, @nd,$offset) = ($_[3], $_[4], $_[6]);
	my @curNode=[$_[2], $_[1]];
	while (@curNode) {
		for $onref (@curNode) {
			my ($a,$b,$i)= (1, '*');
			if ($_[5]) {
				my ($lt,$e,$n)= $_[5]=~ /(?>(<)|>)(=)?(\d+)/;
				$b = $lt?	$e? "{$n}" : '{'.--$n.'}': ($a=$e? $n : $n+1, $b);
			}
			$onref->[1]=~
			/^(<[a-z]\w*[^>]*+>)(?{$offset=$1}) (?:
			((?'at'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>))*+)
			(?{$offset.=$2})
			(?:(?=<$_[0]\b$att (?{$E=1}))?	(?{ $max=0 })
			(?'node'<(\w++)[^>]*+>
			(?{$max=$d if ++$d>$max})
			(?>(?&at)|(?&node))*+<\/\g-1>(?{--$d}))
			(?{if ($max>=$min) {
				push (@$ret, [$onref->[0].$offset, $+{node}]) if $E and ++$i>=$a;
				push (@nd, [$onref->[0].$offset, $+{node}]) if $max>$min;
				$E=0}
			$offset.=$+{node} })
			)?) $b /x
		}
		@curNode=@nd; @nd=();
	}
	return !@$ret
}

sub getAllDepthAatt {	# $_[0] attribute  $_[1] el under which to search  $_[2] its offset  $_[4] depth
	my ($att, $ret, $min, $max, $E, $onref, $d, @nd,$offset)= ($_[0], $_[3], $_[4]);
	my @curNode=[$_[2], $_[1]];
	while (@curNode) {
		for $onref (@curNode) {
			$onref->[1]=~
			/^(<[a-z]\w*[^>]*+>)(?{$offset=$1}) (?:
			((?'at'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>))*+)
			(?{$offset.=$2})
			(?:(?=<\w+$att (?{$E=1}))?	(?{ $max=0 })
			(?'node'<(\w++)[^>]*+>
			(?{$max=$d if ++$d>$max})
			(?>(?&at)|(?&node))*+<\/\g-1>(?{--$d}))
			(?{ if ($max>=$min) {
				push (@$ret, [$onref->[0].$offset, $+{node}]) if $E;
				push (@nd, [$onref->[0].$offset, $+{node}]) if $max>$min;
				$E=0}
			$offset.=$+{node} })
			)?)* /x
		}
		@curNode=@nd; @nd=();
	}
	return !@$ret
}
# These subs' $_[0] is the searched ele/att.  Return 1 on failure to find. Else 0 and offset & node pairs in the 4rd arg, $_[3]

my @res;
sub getE_Path_Rec {			# path,  offset - node pair
	my ($ADepth, $tag, $nth,$nrev,$range, $att, $aatt, $path, $R)=$_[0]=~
	m{ ^(/)?/ (?> ([^/@[]+) (?> \[ (?>([1-9]+ | last\(\)-([1-9]+)) | position\(\)(?!<1)([<>]=?\d+) | @([^]]+) ) \] )? | @([a-z]\w*) ) (.*) }x;
	$att=$att? '\s+'.$att :''; $aatt=$aatt? '\s+'.$aatt :'';
	for (@{$_[1]}) {
		my @OffNode;
		if ($ADepth) {
			my $depth=1+(()=$path=~/\//g);					# offset-node pair return is in @OffNode..
			if ($tag?
				$nth?
					getAllDepth ($tag, $nth, $_->[1], \@OffNode, $_->[0], $depth, $nrev)
				: getAllDepNthRnAtt ($tag, $_->[1], $_->[0], \@OffNode, $depth, $range, $att)
			: getAllDepthAatt ($aatt, $_->[1], $_->[0], \@OffNode, $depth) ){
					next if length($_->[0]) < length(${$_[1]}[-1]->[0]);			# no error return yet if there's node else, checked by offset length
					return !@res}
		}elsif ($nth) {
			if (getNthEAtt ($tag, $nth, $_->[1], \@OffNode, $nrev)) {	
				next if length($_->[0]) < length(${$_[1]}[-1]->[0]);
				return !@res}
			${$OffNode[0]}[0]=$_->[0].${$OffNode[0]}[0];
		}else {
			if (getAllNthEAtt ($tag, $_->[1], $_->[0], \@OffNode, $range, $att)) {
				next if length($_->[0]) < length(${$_[1]}[-1]->[0]);
				return !@res}
		}
		if ($path)	{		$R=getE_Path_Rec ($path, \@OffNode)					# ..to always propagate to the next
		}	else {					push (@res, @OffNode)	}
	}
	return $R
}

my ($whole, $trPath, @valid, $O, $CP);
if (@ARGV) {
	$trPath=shift;	$O=shift;
	undef local $/;$whole=<>
}else {
	print "Element path is of Xpath form e.g:\n\thtml/body/div[1]//div[1]/div[2]\nmeans find in a given HTML or XML file, the second div tag element that is under the first\ndiv element anywhere, in breadth or depth, lives under the first div element, under any\nbody element, under any html element.\n\nTo put multiply at once, put one after another delimited by ;\nPut element path: ";
	die "No any Xpath given\n" if ($trPath=<>)=~/^\s*$/;
	for (split /;/,$trPath) {
		my $xpath=qr{^\h* (?:
		(/?/[a-z]\w*+ (?> \[ (?>[1-9]+ | last\(\)-[1-9]+ | position\(\)(?!<1)[<>]=?[1-9]+ | @[a-z]+(?:=\w+)?) \] )? | /?/@[a-z]\w*)
		| \.\.? ) (?1)*+ [/\h]*$ }x;
		if (/$xpath/) {
			s#\h|/+$##g;
			if (/^[^\/]/) {
				if(!$CP){
					print "\n'$_'\nis relative to base/current path which is now empty, specify one:\n";
					print "\n'$CP' is not a valid xpath" while (($CP=<>=~s#\s|/$##gr) !~ $xpath);
					$CP=~s#\h|/+$##g
				}
				s#^\./##;
				if (/^\.\./) {	$CP=~s#/?[^/]+$##;	s#^../##	}
				$_="$CP/$_"
			}
			push (@valid, $_);
		}else {
			print "'$_' is invalid Xpath\nSkip or abort it? (S: skip.  any else: abort) ";my $y=<>;
			if ($y=~/^s/i) { next
			}else{	die "Aborting\n"}
	}}
	print "\nHTML/XML file name to process: ";
	my $file=<>=~s/^\h+//r=~ s/\s+$//r;
	$!=1;-e $file or die "\n'$file' not exist\n";
	$!=2;open R,"$file" or die "\nCannot open '$file'\n";
	undef local $/;$whole=<R>;close R;
	print "\nProcessing HTML document '$file'...\n"
}

die "\nCan't parse the ill formed HTML because likely of unbalanced tag pair\n" unless
$whole=~m{^(<(?>!DOCTYPE|xml)[^>]*+>[^<]*)(<([a-z]\w*)[^>]*+>(?'cnt'(?>[^<>]|<(?>meta|link|input|img|hr|base)\b[^>]*+>|<([a-z]\w*+)[^>]*+>(?&cnt)*+</\g-1>))*?</\g3>)(?&cnt)*};
my @in=[$1,$2]; my $firsTAG=$3;

my ($ER, @path, @fpath, @miss, @short);
for (sort{length $a cmp length $b} @valid) {
	if ($ER) {
		print "\nSkip it to process the next path? (Y/Enter: yes. any else: Abort) ";
		<>=~/^(?:\h*y)?$/i or die "Aborting\n"}
	@res=();
	m{^/([a-z]\w*)(/.*)};
	if ($firsTAG ne $1 or $ER=getE_Path_Rec ($2, \@in)) {
		push(@miss,$_);
		print "\nCan't find '$_'"
	}else {
		push (@path, [$_, [@res]]);
		my $cur=$_;			# Optimize removal: filter out longer path whose head is the same as shorter one
		for (@short) {
			goto P if $cur =~ /^\Q$_\E/}
		push (@fpath, @res);
		P:
		push (@short, $_)
	}
}

if (@miss){
	if (@path){
		print "\nKeep processing ones found? (Y/Enter: yes. any else: Abort) ";
		<>=~s/^\h+//r =~/^y?$/i or die "Aborting\n";
	}else{	print "\nNothing was done\n";exit
}}
unless	(@ARGV){
	print "\nWhich operation will be done :\n- Remove\n- Get\n(R: remove   Else key: just get it) ";
	$O=<>=~s/^\h+//r=~ s/\s+$//r;
	print 'File name to save the result: (hit Enter to standard output) ';
	my $of=<>=~s/^\h+//r=~ s/\s+$//r;
	open W,">","$of" or die "Cannot open '$of'\n" if $of
}
if($#path) {print "\nProcessing the path:";print "\n$_->[0]" for(@path)}

for ($O){
if (! /^r/i) {
	my $o;for (@path) {
		$o.="\n$_->[0]:\n";
		$o.="\n$_->[1]\n=============\n" for @{$_->[1]}
	}
	fileno W? print W $o:print $o;
	last
}

@fpath=sort {length $b->[0] <=> length $a->[0]} @fpath;
$whole=~ s/\A(\Q$_->[0]\E)\Q$_->[1]\E(.*)\Z/$1$2/s	for (@fpath);
fileno W? print W $whole:print "\n\nRemoval result:\n$whole"
}
close W;
