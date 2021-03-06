package ParsCit::CitationContext;
#
# Utility functions for finding citation contexts after citation
# parsing.  The idea is to build regular expressions that could match
# citation references in the body text and scan the body text for
# occurrences.  The size of the context returned can be configured
# in ParsCit::Config::contextRadius.
#
# Isaac Councill, 7/20/07
#
use ParsCit::Config;
use utf8;

my $contextRadius = $ParsCit::Config::contextRadius;
my $maxContexts = $ParsCit::Config::maxContexts;
my $premark = $ParsCit::Config::context_premark;
my $postmark = $ParsCit::Config::context_postmark;

##
# Build a list of potential regular expressions based on the supplied
# citation marker and applies the expressions to the specified body text.
# Returns a reference to a list of strings that match the expressions,
# expanded to radius $contextRadius.
##
sub getCitationContext {
    my ($rBodyText, $marker) = @_;

    my ($prioritize, @markers) = guessPossibleMarkers($marker);
    my @matches = ();

    my $contextsFound = 0;
    foreach my $mark (@markers) {
	while (($contextsFound < $maxContexts) &&
	       $$rBodyText =~ m/(.{$contextRadius}$mark.{$contextRadius})/gs) {
	    my $match = $1;
	    $match =~ s/^(.*?)($mark)(.*)$/$1$premark$2$postmark$+/;
	    push @matches, $match;
	    $contextsFound++;
	}
	if (($prioritize > 0) && ($#matches >= 0)) {
	    last;
	}
    }
    return \@matches;

}  # getCitationContext


##
# Builds a list of regular expressions based on the supplied
# citation marker that may indicate a citation reference in
# body text.  The first value returned is a parameter indicating
# whether the list should be prioritized (i.e., if matches to
# one element are found, don't try to match subsquent expressions),
# with 0 indicating no prioritization and 1 indicating otherwise.
##
sub guessPossibleMarkers {
    my $marker = shift;
    if ($marker =~ m/^([\[\(])([\p{IsUpper}\p{IsLower}\-\d]+)([\]\)])/) {
	my $open = makeSafe($1);
	my $mark = makeSafe($2);
	my $close = makeSafe($3);
	my $refIndicator = "$open([\p{IsUpper}\p{IsLower}\\-\\d]+[;,] *)*$mark([;,] *[\p{IsUpper}\p{IsLower}\\-\\d]+)*$close";
	return (0, $refIndicator);
    }
    if ($marker =~ m/^(\d+)\.?/) {
	my $square = "\\[(\\d+[,;] *)*$1([;,] *\\d+)*\\]";
	my $paren = "\\((\\d+[,;] *)*$1([,;] *\\d+)*\\)";
	return (1, $square, $paren);
    }
    if ($marker =~ m/^([\p{IsUpper}\p{IsLower}\-\.\']+(, )*)+\d{4}/) {
	my @tokens = split ", ", $marker;
	my $year = $tokens[$#tokens];
	my @names = @tokens[0..$#tokens-1];
	my @possibleMarkers = ();
	if ($#names == 0) {
	    push @possibleMarkers, $names[0].",? $year";
	}
	if ($#names == 1) {
	    push @possibleMarkers, $names[0]." and ".$names[1].",? $year";
	    push @possibleMarkers, $names[0]." & ".$names[1].",? $year";
	}
	if ($#names > 1) {
	    map { $_ = makeSafe($_) } $names;
	    map { $_ = $_."," } @names;
	    my $lastAuth1 = "and ".$names[$#names];
	    my $lastAuth2 = "& ".$names[$#names];
	    push @possibleMarkers,
	      join " ", @names[0..$#names-1], $lastAuth1, $year;
	    push @possibleMarkers,
	      join " ", @names[0..$#names-1], $lastAuth2, $year;

	    push @possibleMarkers, $names[0]."? et al\\\.?,? $year";
	}
	for (my $i=0; $i<=$#possibleMarkers; $i++) {
	    my $safeMarker = $possibleMarkers[$i];
	    $safeMarker =~ s/\-/\\\-/g;
	    $possibleMarkers[$i] = $safeMarker;
	}
	return (0, @possibleMarkers);
    }
    return makeSafe($marker);

}  # guessPossibleMarkers


##
# Prepare strings for safe inclusion within a regular expression,
# escaping control characters.
##
sub makeSafe {
    my $marker = shift;
    $marker =~ s/\\/\\\\/g;
    $marker =~ s/\-/\\\-/g;
    $marker =~ s/\[/\\\[/g;
    $marker =~ s/\]/\\\]/g;
    $marker =~ s/\(/\\\(/g;
    $marker =~ s/\)/\\\)/g;
    $marker =~ s/\'/\\\'/g;
    $marker =~ s/\"/\\\"/g;
    $marker =~ s/\+//g;
    $marker =~ s/\?//g;
    $marker =~ s/\*//g;
    $marker =~ s/\^//g;
    $marker =~ s/\$//g;
    $marker =~ s/\./\\\./g;
    return $marker;

} # makeSafe


1;
