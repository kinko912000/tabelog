use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;

# urlを指定する

my $tokyo = parser('http://tabelog.com/sitemap/tokyo/');
# DOM操作してトピックの部分だけ抜き出す。
# <div id='topicsfb'><ul><li>....の部分を抽出する


###東京の駅ごとのurl取得
my @station_url;
foreach my $a ($tokyo->look_down('id','arealst_sitemap')->find("a")) {
    push @station_url ,$a->attr('href');
}

#print @station_url;


###駅ごとのあいうえお順にならんだリストのurlを取得

my @station_url_aioue;
my $station;

foreach my $a (@station_url) {
	$station = parser($a);
#	print $station->look_down('id','arealst_sitemap')->find("a")->attr('href');

	foreach my $b ($station->look_down('id','arealst_sitemap')->find("a")) {
    	push @station_url_aioue,$b->attr('href');
	}
}






###あいうえお順のurlリストから店のurlを取得

my $restaurant;

my $file  = "list.csv";
open(my $fh,'>',$file) or die "Cannot open $file : $!";

foreach my $a (@station_url_aioue) {
	$restaurant = parser($a);
#	print $station->look_down('id','arealst_sitemap')->find("a")->attr('href');

	foreach my $b ($restaurant->look_down('id','rstlst_sitemap')->find("a")) {
    	print $fh ("http://tabelog.com/".$b->attr('href')."\n");
	}
}


###ファイルからお店のurlを取得して内容を保存
my $list  = "list.csv";
open(my $fh_list,'<',$list) or die "Cannot open $list: $!";

my $page_content;
my $title;

while (my $line = readline $fh_list){
	chomp $line;

	$page_content = scraping($line);
	$title = (split(/\//,$line))[6];
	open(my $fh_restaurant,'>',$title."\.txt") or die "Cannot open $list: $!";
	print $fh_restaurant $page_content;

}



sub scraping {
	my $url = shift;
	# IE8のフリをする
	my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";

	# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
	my $ua = LWP::UserAgent->new('agent' => $user_agent);
	my $res = $ua->get($url);
	my $content = $res->content;

	return $content;

}


sub parser {
	my $url = shift;
	# IE8のフリをする
	my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";

	# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
	my $ua = LWP::UserAgent->new('agent' => $user_agent);
	my $res = $ua->get($url);
	my $content = $res->content;

	# HTML::TreeBuilderで解析する
	my $tree = HTML::TreeBuilder->new;
	$tree->parse($content);

	return $tree;


}

#my @items =  $tree->look_down('id', 'topicsfb')->find('li');
#print $_->as_text."\n" for @items; 