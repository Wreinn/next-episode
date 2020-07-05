# next-episode.pl

use strict;
use warnings;

use File::Find;
use File::Slurp;

use 5.010;

use constant BACKGROUND_CMD   => 'START /B'; # ref: https://superuser.com/a/591084
use constant LASTWATCHED_FILE => '';
use constant MEDIA_PLAYER     => '';

start_episode(lastwatched_episode() + 1);

exit;

sub lastwatched_episode {
    my $lastwatched_episode = read_file(LASTWATCHED_FILE);
    ($lastwatched_episode) = $lastwatched_episode =~ /(\d+)/;
    
    die 'last episode is invalid' if ! $lastwatched_episode;

    return $lastwatched_episode;
}

sub start_episode {
    my $episode = shift;

    my $episode_filename = episode_filename($episode)
        or die "No file found for: $episode";

    my $episode_path = join('\\', '.', $episode_filename);
    
    my $cmd = sprintf('%s "%s" "%s"', BACKGROUND_CMD, MEDIA_PLAYER, $episode_path);

    qx{$cmd};
}

sub episode_filename {
    my $episode_number = shift or die 'missing episode number';

    $episode_number = sprintf('%03i', $episode_number);

    my @episodes;
    find(sub { push @episodes, $_ if /_\Q$episode_number\E_/ }, '.');

    die 'more than one episode detected' if @episodes > 1;

    return $episodes[0];
}
