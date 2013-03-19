#!/usr/bin/perl -w
use HTML::Template;
use strict;
my $index_tmpl = './template/index.html';
my $catagory_tmpl = './template/catagory.html';
my $post_tmpl = './template/post.html';

my @posts;
my @catagories;

cata_list();
#dump_post();
render_index();
render_catagory(); 
render_post();

sub dump_post {
    foreach (@posts) {
        print "TITLE: ".$_->{"POST_TITLE"}."\n";
        print "DATE: ".$_->{"POST_DATE"}."\n";
        print "CATAGORY: ".$_->{"POST_CATAGORY"}."\n";
        print "CONTENT: ".$_->{"POST_CONTENT"}."\n";
        print "LINK: ".$_->{"POST_LINK"}."\n";
    }
}

sub cata_list {
    my $cata_dir = './posts';
    opendir CATA_DIR, $cata_dir;
    foreach (readdir CATA_DIR) {
        my %row_data = ();
        if ($_ ne '.' and $_ ne '..') {
            $row_data{"CATA_NAME"} = $_;
            $row_data{"CATA_LINK"} = "/blog/".$_;
            post_list($_);
            push(@catagories, \%row_data);
        }
    }
    close CATA_DIR;
    @posts = sort {$a->{"POST_DATE"} cmp $b->{"POST_DATE"}} @posts;
}

sub post_list {
    my $cata = $_[0];
    opendir CATA_DIR, 'posts/'.$cata;
    foreach (readdir CATA_DIR) {
        my %post_data = ();
        if ($_ =~ /.+\.md$/) {
            my $file = 'posts/'.$cata.'/'.$_;
            my $content;
            my $date;
            my $title;

            open FILE, $file;
            while(defined(my $line = <FILE>)) {
                if ($. == 1) {
                    $line =~ /[ \t]*date[ ]*:[ ]*(.+)$/;
                    $date = $1;
                } elsif ($. == 2) {
                    $line =~ /[ \t]*title[ ]*:[ ]*(.+)$/;
                    $title = $1;
                } else {
                    $content .= $line;
                }
            }
            $post_data{"POST_TITLE"} = $title;
            $post_data{"POST_DATE"} = $date;
            $post_data{"POST_CONTENT"} = $content;
            $post_data{"POST_CATAGORY"} = $cata;
            $file =~ s/.md/.html/;
            $file =~ s/posts\///;
            $post_data{"POST_LINK"} = "/blog/$file";
            push(@posts, \%post_data);

            close FILE;
        }
    }
    close CATA_DIR;
}

sub render_index {
    my $templ = HTML::Template->new(filename => $index_tmpl);
    my @index_posts;
    foreach (@posts) {
        my %index_post;
        $index_post{"POST_LINK"} = $_->{"POST_LINK"};
        $index_post{"POST_TITLE"} = $_->{"POST_TITLE"};
        push (@index_posts, \%index_post);
    }
    $templ->param(POSTS => \@index_posts);
    $templ->param(CATAGORIES => \@catagories);

    open INDEX, ">index.html";
    print INDEX $templ->output();
    close INDEX;
}

sub render_catagory {
    foreach my $cata (@catagories) {
        my $templ = HTML::Template->new(filename => $catagory_tmpl);
        my @index_posts;
        foreach (@posts) {
            my %index_post;
            if ($_->{"POST_CATAGORY"} eq $cata->{"CATA_NAME"}) {
                $index_post{"POST_LINK"} = $_->{"POST_LINK"};
                $index_post{"POST_TITLE"} = $_->{"POST_TITLE"};
                push (@index_posts, \%index_post);
            }
        }
        $templ->param(CATA_NAME => $cata->{"CATA_NAME"});
        $templ->param(POSTS => \@index_posts);
        $templ->param(CATAGORIES => \@catagories);

        rmdir "blog/".$cata->{"CATA_NAME"};
        mkdir "blog/".$cata->{"CATA_NAME"};
        my $link = ".".$cata->{"CATA_LINK"}."/index.html";
        open CATAGORY, ">$link";
        print CATAGORY $templ->output();
        close CATAGORY;
    }
}

sub render_post {
    foreach my $post (@posts) {
        my $templ = HTML::Template->new(filename => $post_tmpl);
        $templ->param(POST_TITLE => $post->{"POST_TITLE"});
        $templ->param(POST_DATE => $post->{"POST_DATE"});
        $templ->param(POST_CONTENT => $post->{"POST_CONTENT"});
        $templ->param(CATAGORIES => \@catagories);

        my $link = ".".$post->{"POST_LINK"};
        open POST, ">$link";
        print POST $templ->output();
        close POST;
    }
}
