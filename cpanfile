requires "Bencode" => "0";
requires "Carp" => "0";
requires "Class::Accessor::Fast" => "0";
requires "DBIx::Class" => "0";
requires "DateTime" => "0";
requires "Digest::SHA1" => "0";
requires "Exporter" => "0";
requires "IP::Country::Fast" => "0";
requires "Net::IP" => "0";
requires "NetAddr::IP" => "0";
requires "Path::Class" => "0";
requires "base" => "0";
requires "constant" => "0";
requires "strict" => "0";
requires "version" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::More" => "0";
  requires "perl" => "5.006";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::Pod" => "1.41";
};
