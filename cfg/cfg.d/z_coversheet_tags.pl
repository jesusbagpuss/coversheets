
# Example definition of tags that can be used in the coversheets
# when using potential utf-8 strings, use the encode() method on the string:
$c->{coversheet}->{tags} = {

	'title' 	=>  sub { my ($eprint) = @_; return  EPrints::Utils::tree_to_utf8($eprint->render_value('title')) ; },

	'type' 		=>  sub { my ($eprint) = @_; return EPrints::Utils::tree_to_utf8($eprint->render_value('type')); },

	'url' 		=>  sub { my ($eprint) = @_; return $eprint->get_url; },

	'date'		=> sub {
		my( $eprint ) = @_;
		if( $eprint->is_set( "date" ) )
		{
			my $date = $eprint->get_value( "date" );
			$date =~ /^([0-9]{4})/;
			return $1 if defined $1;
		}
		return '';
	},

	'citation'      =>  sub { 
		my ($eprint) = @_; 
		my $cit_str = EPrints::Utils::tree_to_utf8($eprint->render_citation,undef,undef,undef,1 );
		return $cit_str; 
	},

	'creators'      =>  sub { 
		my ($eprint) = @_; 
		my $field = $eprint->dataset->field("creators_name");
		if ($eprint->is_set( "creators_name" ) ) 
		{
			return  EPrints::Utils::tree_to_utf8($field->render_value($eprint->repository, $eprint->get_value("creators_name"), 0, 1) ); 
		}
		elsif ($eprint->is_set( "editors_name" ) )
		{
			$field = $eprint->dataset->field("editors_name");
			return "Edited by: " . EPrints::Utils::tree_to_utf8($field->render_value($eprint->repository,$eprint->get_value("editors_name"), 0, 1) );
		}
		else
		{
			return '';
		}
	},

	'doi_url'	=>  sub {
		my ($eprint) = @_; 
		if ($eprint->is_set( "id_number" ) )
		{
			my $value = $eprint->get_value( "id_number" );

			# JLRS 2014-04-30
			# remove trailing slash too! 
			# $value =~ s|^http://dx\.doi\.org||;
			$value =~ s|^http://dx\.doi\.org/||;
			if( $value !~ /^(doi:)?10\.\d\d\d\d\// )
			{
				return $value;
			}
			else
			{
				$value =~ s/^doi://;
				#return "http://dx.doi.org/$value";
				return "https://doi.org/$value";
			}
		}
		else
		{
			return '';
		}
	},
	'coversheet_statement'		=> sub {
		my( $eprint ) = @_;
		if( $eprint->is_set( "coversheet_statement" ) )
		{
			return EPrints::Utils::tree_to_utf8( $eprint->render_value( 'coversheet_statement' ) );
		}
		return '';
	},
	'version' => sub {
		my( $eprint, $doc ) = @_;
		if( $doc->is_set( "content" ) ){
			return 'Version: '. EPrints::Utils::tree_to_utf8( $doc->render_value( 'content' ) );
		} else {
			return '';
		}
	},
	'license_statement' => sub {
		my( undef, $doc ) = @_;
		my $repo = $doc->repository;

		if( $doc->exists_and_set( "license" ) && $doc->value( "license" ) ne "unspecified" ){
			my $phraseid = "licenses_coversheet_statement_".$doc->value( "license" );
			if( $repo->get_lang->has_phrase( $phraseid, $repo ) ){
				return $repo->phrase( $phraseid );
			} else {
				return EPrints::Utils::tree_to_utf8( $doc->render_value( 'license' ) );
			}

		} else {
			return $repo->phrase( "licenses_coversheet_statement_NONE" );
		}
	},
};

$c->{coversheet}->{pdfmark} = sub {
	my( $eprint ) = @_;

	my $return_string = "";
	if( $eprint->is_set( "title" ) ){
		$return_string .= "/Title <".unpack("H*",Encode::encode( "UTF-16",EPrints::Utils::tree_to_utf8($eprint->render_value( "title" ) ) ) ).">\n";
	}

	if( $eprint->is_set( "creators_name" ) ){
		$return_string .= "/Author <".unpack("H*",Encode::encode( "UTF-16",EPrints::Utils::tree_to_utf8($eprint->render_value( "creators_name" ) ) ) ).">\n";
	}

	if( $eprint->is_set( "keywords" ) ){
		$return_string .= "/Keywords <".unpack("H*",Encode::encode( "UTF-16",EPrints::Utils::tree_to_utf8($eprint->render_value( "keywords" ) ) ) ).">\n";
	}

	if( $return_string eq "" ){
		return undef;
	} else {
		return "[ $return_string /DOCINFO pdfmark\n";
	}
};

1;
