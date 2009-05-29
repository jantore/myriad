package Myriad::TorrentMeta;

use base qw{ Class::Accessor::Fast };

__PACKAGE__->mk_accessors(qw{
    parent_directory
    files
    name
    piece_length
    announce
    comment
});

use Digest::SHA1;
use Bencode;
use Path::Class;

sub new {
    my ($class, $fields) = shift;
    my $self = $class->SUPER::new($fields);

    # Set some default values.
    $self->files([]);
    $self->piece_length(512 * 1024) if not defined $self->piece_length;

    return $self;
}

sub load_torrent {
    my ($self, $file) = @_;

    # TODO Implement.
}

sub add_file {
    my ($self, $path, $file) = @_;

    #my $path = shift;
    if(ref $path) {
        push(@{ $self->files }, $path);
    } else {

    }

    #push(@{ $self->files }, { file => $file, path => $path });
}

sub read_directory {
    my ($self, $directory) = @_;

    my $path = Path::Class::Dir->new($directory);
    $self->parent_directory($path);
    
    $path->recurse(callback => sub {
        my ($p) = @_;
	return unless -f $p;
        my $file = $p->relative($path);
        $self->add_file($file);
    });

    unless(defined($self->name)) {
        $self->name( $path->relative($path->parent)->stringify );
    }

    #$self->_load_directory($directory);
#     find(sub {
#             my ($path, $file) = ($File::Find::dir, $File::Find::name);
#         return unless -f;
#         $self->add_file($path, $file);
#     }, $directory);
    

    # TODO Set name from directory name if not already set.
}

sub encode {
    my ($self) = @_;

    # Create the file information.
    # TODO Also add MD5 sums.
    my $info = {};
    my @files = @{ $self->files };

    if( scalar(@files) == 1 ) {
        # Single file - simpler info structure.
        my $file = shift(@files);
        $info->{'name'}   = $self->name || $file->basename;
        $info->{'length'} = $file->stat->size;
    } else {
        # Multiple files
        $info->{'name'}  = $self->name
            ;#|| $self->parent_directory->relative($self->parent_directory->parent)->stringify;
        $info->{'files'} = [ map {
            {
                'length' => $_->absolute($self->parent_directory)->stat->size,
                'path'   => [ split(/\//, $_->stringify) ],
            }
        } @files ];
    }
    $info->{'piece length'} = $self->piece_length;
    $info->{'pieces'}       = $self->hash_pieces;

    # Create the metadata structure.
    my $data = {
        'info'          => $info,
        'announce'      => $self->announce,
        'creation date' => time(),
        'created by'    => 'Myriad',
        defined($self->comment) ? ('comment' => $self->comment ) : (),
    };


    return Bencode::bencode($data);
}

sub hash_pieces {
    my ($self) = @_;
    my @files = @{ $self->files };

    my $pieces = "";

    #my $buffer = '';
    my $digest = Digest::SHA1->new();
    my $read = 0;

    my $maxlength = $self->piece_length;

    my $filesdone = 0;
    foreach my $file (@files) {
        $filesdone++;
        #print("Processing file " . $file . "\n");
        my $fh = $file->absolute($self->parent_directory)->openr();
        #open(FILE, "<$file") or die("Can't open file for reading");

        my $numread, $data;
        while( ($numread = read($fh, $data, $maxlength - $read)) != 0 ) {
            $read += $numread;
            $digest->add($data);

            if( $read == $maxlength ) {
                $pieces .= $digest->digest;
                print STDERR "Finished piece " . (length($pieces) / 20) . ", $filesdone files done.\n";

                $digest->reset;
                $read = 0;
            }
        }
    }

    $pieces .= $digest->digest;
    return $pieces;
}

1;
