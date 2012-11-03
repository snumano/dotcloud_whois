package whois::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use Net::DNS;
use Web::Scraper;
use URI;
use Encode;
use Text::Xslate::Util qw(mark_raw);

my $org = '<BR>';
my $netblockowner = '<BR>';
my $nameserver = '<BR>';
my $dnsadmin = '<BR>';
my $nameserver_org = '<BR>';
my $domain = '';
my $domain2 = '<BR>';
my $org1 = '<BR>';
my $org2 = '<BR>';
my $contact1 = '<BR>';
my $contact2 = '<BR>';
my $email = '<BR>';
my $tel = '<BR>';
my $address = '<BR>';
my $ip_prefix = '<BR>';
my $org_ip = '<BR>';
my $ip_provider = '<BR>';
my $result;
my $textarea = '';

any '/' => sub {
    my ($c) = @_;
    $c->render('index.tt');
};

any '/result' => sub {
    my ($c) = @_;

    if ($textarea = $c->req->param('textarea')) {
	chomp($textarea);
	my @strings = split(/\r\n/,$textarea);
	
	for (my $k=0;$k<=$#strings;$k++){
	    $_ = $strings[$k];
	    s/(.+)[\r\n]+/$1/;
	    s/(http\:\/\/)(.+)/$2/;
	    s/(.+?)(\/.*)/$1/;
	    s/\s//g;
	    if(/^$/){
		last;
	    }
	    elsif(/\A\P{Cc}{4,100}/){
		my ($addr,$count_addr,$company_name,$as,$cname) = &host2as($_);
		$addr = "<BR>" if(!$addr);
		$count_addr = "<BR>" if(!$count_addr);
		$company_name = "<BR>" if(!$company_name);
		$as = "<BR>" if(!$as);
		
		my @fqdn = split(/\./,$_);
	      outer: for(my $i=0;$i<$#fqdn;$i++){
		  $domain = "";
		  
		  for(my $j=$i;$j<=$#fqdn;$j++){
		      $domain .= $fqdn[$j].".";
		  }
		  chop($domain);
		  
		  ($domain2,$org1,$org2,$contact1,$contact2,$email,$tel,$address) = &whois_domain($domain,'JPRS');
		  if($org1 =~ /\<BR\>/ && $org2 =~ /\<BR\>/ && $contact1 =~ /\<BR\>/ && $contact2 =~ /\<BR\>/ && $email =~ /\<BR\>/ && $tel =~ /\<BR\>/ && $address =~ /\<BR\>/){
		      ($domain2,$org1,$org2,$contact1,$contact2,$email,$tel,$address) = &whois_domain($domain,'NON-JPRS');
		      if($org1 =~ /\<BR\>/ && $org2 =~ /\<BR\>/ && $contact1 =~ /\<BR\>/ && $contact2 =~ /\<BR\>/ && $email =~ /\<BR\>/ && $tel =~ /\<BR\>/ && $address =~ /\<BR\>/){
			  
			  if($org1 =~ /\<BR\>/ && $org2 =~ /\<BR\>/ && $contact1 =~ /\<BR\>/ && $contact2 =~ /\<BR\>/ && $email =~ /\<BR\>/ && $tel =~ /\<BR\>/ && $address =~ /\<BR\>/){
#                       ($domain2,$org1,$org2,$contact1,$contact2,$email,$tel,$address) = &whois_domain($domain,'WHOIS');
			      if($org1 =~ /\<BR\>/ && $org2 =~ /\<BR\>/ && $contact1 =~ /\<BR\>/ && $contact2 =~ /\<BR\>/ && $email =~ /\<BR\>/ && $tel =~ /\<BR\>/ && $address =~ /\<BR\>/){
				  
				  next outer;
			      }
			      else{
				  last outer;
			      }
			  }
			  else{
			      last outer;
			  }
		      }
		      else{
			  last outer;
		      }
		  }
		  else{
		      last outer;
		  }
	      }
		($ip_prefix,$org_ip,$ip_provider) = &whois_ip($addr,'JPNIC');
		if($ip_prefix =~ /\<BR\>/ && $org_ip =~ /\<BR\>/ && $ip_provider =~ /\<BR\>/){
		    ($ip_prefix,$org_ip,$ip_provider) = &whois_ip($addr,'APNIC');
		}
		
		if($domain){
		    $domain =~ s/">/" TARGET="_blank">/;
		}

		$result->[$k]->{fqdn} = $_;
		$result->[$k]->{addr} = $addr;
		$result->[$k]->{count_addr} = $count_addr;
		$result->[$k]->{cname} = mark_raw($cname);
		$result->[$k]->{domain2} = mark_raw($domain2);
		$result->[$k]->{org1} = mark_raw($org1);
		$result->[$k]->{org2} = mark_raw($org2);
		$result->[$k]->{contact1} = mark_raw($contact1);
		$result->[$k]->{contact2} = mark_raw($contact2);
		$result->[$k]->{email} = mark_raw($email);
		$result->[$k]->{tel} = mark_raw($tel);
		$result->[$k]->{address} = mark_raw($address);
		$result->[$k]->{ip_prefix} = mark_raw($ip_prefix);
		$result->[$k]->{org_ip} = mark_raw($org_ip);
		$result->[$k]->{ip_provider} = mark_raw($ip_provider);
		$result->[$k]->{as} = $as;
		$result->[$k]->{company_name} = mark_raw($company_name);
	    }
	}
    }
    $c->render('result.tt' => {results => $result,});
};


sub whois_domain{
    my $domain = '<BR>';
    my $whois_server = '';

    ($domain,$whois_server) = @_;
    my $uri;

    if($domain && $domain =~ /\>(.+)\</){
        $domain = $1;
    }
    my $domain2 = '<BR>';
    my $org1 = '<BR>';
    my $org2 = '<BR>';
    my $contact1 = '<BR>';
    my $contact2 = '<BR>';
    my $email = '<BR>';
    my $tel = '<BR>';
    my $address = '<BR>';
    my ($scraper,$result);

    if($domain && $whois_server && $whois_server =~ /^JPRS$/){
        $domain2 = "<A HREF=\"http://whois.jprs.jp/?key=".$domain."\" TARGET=\"_blank\">".$domain."</A>";
        $uri = URI->new("http://whois.jprs.jp/?key=$domain");
        $scraper = scraper {
            process '/html/body/pre','info' => 'TEXT';
        };
        eval {$result = $scraper->scrape($uri)};
    }
    elsif($domain && $whois_server && $whois_server =~ /^NON-JPRS$/){
        $domain2 = "<A HREF=\"http://whois.domaintools.com/".$domain."\" TARGET=\"_blank\">".$domain."</A>";
        $result->{info} = `/usr/bin/whois $domain`;
    }
=pod
    elsif($domain && $whois_server && $whois_server =~ /^DOMAINTOOLS$/){
        $uri = URI->new("http://whois.domaintools.com/$domain");
        $domain2 = "<A HREF=\"http://whois.domaintools.com/".$domain."\" TARGET=\"_blank\">".$domain."</A>";
        $scraper = scraper {
            process '/html/body/div[6]/div/div/div[3]/div/div[2]/div/div[2]/div/div[2]/div/div/div/div/div/div/div/div[2]/div/div/div[2]','info' => 'HTML';
        };
        eval {$result = $scraper->scrape($uri)};
    }
    elsif($domain && $whois_server && $whois_server =~ /^WHOIS$/){
        $uri = URI->new("http://who.is/whois/$domain");
        $domain2 = "<A HREF=\"http://who.is/whois/".$domain."\" TARGET=\"_blank\">".$domain."</A>";
        $scraper = scraper {
            process '/html/body/div/div[2]/div[2]/div[13]','info' => 'HTML';
        };
        eval {$result = $scraper->scrape($uri)};
    }
=cut

    if($result->{info}){
        if($whois_server =~ /^DOMAINTOOLS$/){
            $result->{info} =~ s/\<br\s\/\>/\n/g;
            $result->{info} =~ s/\<.+\>/\n/g;
        }
        else{
            $result->{info} =~ s/\<br\s\/\>/\n/g;
        }
    }

    if($result->{info} && ($result->{info} =~ /\[組織名\]\s+(.+)\n/ || $result->{info} =~ /\[登録者名\]\s+(.+)\n/)){
        $org1 = $1;
        $org1 =~ s/[\r\n]//g;
    }

    if($result->{info} && ($result->{info} =~ /\[Organization\]\s+(.+)\n/ || $result->{info} =~ /\[Registrant\]\s+(.+)\n/)){
        $org2 = $1;
        $org2 =~ s/[\r\n]//g;
    }
    elsif($result->{info} && $result->{info} =~ /Registrant\:.*\n\s*(.+)\n\s*(.+)\n/){
        $org2 = $1." ".$2;
        $org2 =~ s/[\r\n]//g;
    }
    elsif($result->{info} && $result->{info} =~ /Registrant\sOrganization\:\s*(.+)\n/){
        $org2 = $1;
        $org2 =~ s/[\r\n]//g;
    }
    elsif($result->{info} && $result->{info} =~ /Organisation Name(.+)\n/){
        $org2 = $1;
        $org2 =~ s/[\r\n]//g;
        $org2 =~ s/(\S*\s?)(.+)/$2/;
    }

    if($whois_server =~ /^JPRS$/ && $result->{info} && $result->{info} =~ /\[登録担当者\]\s+(.+)\n/){
        my $contact_tmp = $1;
        $contact_tmp =~ s/[\r\n]//g;
        $uri = URI->new("http://whois.jprs.jp/?key=${contact_tmp}&type=poc");
        $scraper = scraper {
            process '/html/body/pre','info' => 'TEXT';
        };
        eval {$result = $scraper->scrape($uri)};
    }

    if($result->{info} && ($result->{info} =~ /\[名前\]\s+(.+)\n/ || $result->{info} =~ /\[氏名\]\s+(.+)\n/)){
        $contact1 = $1;
        $contact1 =~ s/[\r\n]//g;
    }
    if($result->{info} && ($result->{info} =~ /\[Name\]\s+(.+)\n/ || $result->{info} =~ /\[Last, First\]\s+(.+)\n/ || $result->{info} =~ /Admin\sName(.+)\n/)){
        $contact2 = $1;
        $contact2 =~ s/[\r\n]//g;
        $contact2 =~ s/(\S*\s?)(.+)/$2/;
    }
    elsif($result->{info} && $result->{info} =~ /Administrative\sContact:(.+)Technical\sContact/s){
        $contact2 = $1;
        $contact2 =~ s/[\r\n]/ /g;
        $contact2 =~ s/\s+/ /g;
    }

    if($result->{info} && ($result->{info} =~ /\[Email\]\s+(\S+?)[\r\n]/ || $result->{info} =~ /\[電子メイル\]\s+(\S+?)[\r\n]/)){
        $email = $1;
        $email =~ s/[\r\n]//g;
    }
    elsif($result->{info} && $result->{info} =~ /Admin\sEmail(.+)\n/){
        $email = $1;
        $email =~ s/[\r\n]//g;
        $email =~ s/(\S*\s?)(.+)/$2/;
    }

    if($result->{info} && $result->{info} =~ /\[電話番号\]\s+\n/){
        $tel = '<BR>';
    }
    elsif($result->{info} && $result->{info} =~ /\[電話番号\]\s+(\S.+)\n/){
        $tel = $1;
        $tel =~ s/[\r\n]//g;
    }
    elsif($result->{info} && $result->{info} =~ /Admin\sPhone(.+)\n/){
        $tel = $1;
        $tel =~ s/[\r\n]//g;
        $tel =~ s/(\S*\s?)(.+)/$2/;
    }

    if($result->{info} && $result->{info} =~ /\[住所\]\s+(.+?)\[Postal/s){
        $address = $1;
        $address =~ s/[\r\n]//g;
        $address =~ s/\s//g;
    }
    elsif($result->{info} && $result->{info} =~ /Admin\sCity\:\s(.+)\n\s*Admin\sState\:\s+(.+)\n.+Admin\sCountry\:\s+(.+?)\n/s){
        $address = $1.$2.$3;
        $address =~ s/[\r\n]//g;
        $address =~ s/\s//g;
    }
    elsif($result->{info} && $result->{info} =~ /Admin\sAddress(.+)\n\s+Admin\sEmail/s){
        $address = $1;
        $address =~ s/Admin\sAddress/,/g;
        $address =~ s/[\r\n]//g;
        $address =~ s/\s//g;
        $address =~ s/\.//g;
   }
    return ($domain2,$org1,$org2,$contact1,$contact2,$email,$tel,$address);
}

sub whois_ip{
    my ($ip,$whois_server) = @_;
    my $ip_prefix = '<BR>';
    my $org_ip = '<BR>';
    my $ip_provider = '<BR>';
    my ($scraper,$result);
    my $uri;

    if($ip =~ /\d+\.\d+\.\d+\.\d+/){

        if($whois_server =~ /^JPNIC$/){
            $uri = URI->new("http://whois.nic.ad.jp/cgi-bin/whois_gw?key=$ip");
            $scraper = scraper {
                process '/html/body/pre','info' => 'TEXT';
            };
            eval {$result = $scraper->scrape($uri)};
        }
        elsif($whois_server =~ /^APNIC$/){
#            $result->{info} = `/usr/bin/whois $ip`;
            $uri = URI->new("http://wq.apnic.net/apnic-bin/whois.pl?searchtext=$ip");
            $scraper = scraper {
                process '/html/body/div/div[2]/form/pre[3]','info' => 'TEXT';
            };
            eval {$result = $scraper->scrape($uri)};
        }


        if($whois_server =~ /^JPNIC$/ && $result->{info} && ($result->{info} =~ /\[IPネットワークアドレス\]\s+(.+)\n/ || $result->{info} =~ /CIDR\:\s+(.+)\n/)){
            $ip_prefix = $1;
            chomp($ip_prefix);
            $ip_prefix = "<A HREF=\"http://whois.nic.ad.jp/cgi-bin/whois_gw?key=".$ip."\" TARGET=\"_blank\">".$ip_prefix."</A>";
        }
        elsif($whois_server =~ /^APNIC$/ && $result->{info} && ($result->{info} =~ /CIDR\:\s+(.+)\n/ || $result->{info} =~ /inetnum\:\s+(.+)\n/ || $result->{info} =~ /NetRange\:\s+(.+)\n/)){
            $ip_prefix = $1;
            chomp($ip_prefix);
            $ip_prefix = "<A HREF=\"http://wq.apnic.net/apnic-bin/whois.pl?searchtext=".$ip."\" TARGET=\"_blank\">".$ip_prefix."</A>";
        }

        if($whois_server =~ /^JPNIC$/ && $result->{info} && ($result->{info} =~ /\[組織名\]\s+(.+)\n/ || $result->{info} =~ /OrgName\:\s+(.+)\n/ || $result->{info} =~ /netname\:\s+(.+)\n/)){
            $org_ip = $1;
            chomp($org_ip);
        }
        elsif($whois_server =~ /^APNIC$/ && $result->{info} && ($result->{info} =~ /role\:\s+(.+)\n/ || $result->{info} =~ /OrgName\:\s+(.+)\n/)){
            $org_ip = $1;
            chomp($org_ip);
        }

        if($result->{info} && $result->{info} =~ /上位情報\n----------\n\s*(.+)\n/){
            $ip_provider = $1;
            chomp($ip_provider);
        }
    }
    return ($ip_prefix,$org_ip,$ip_provider);
}

sub netcraft{
    my $host = $_[0];
    my $url = "http://".$host;
    my $org = '<BR>';
    my $netblockowner = '<BR>';
    my $nameserver = '<BR>';
    my $dnsadmin = '<BR>';
    my $nameserver_org = '<BR>';
    my $domain = '<BR>';
    my ($scraper,$result);

    my $uri = URI->new("http://toolbar.netcraft.com/site_report?url=$url");

    #org
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[7]/td[2]','list[]' => 'TEXT';
    };
    eval {$result = $scraper->scrape($uri)};
    if($result->{list}[0]){
        $org = $result->{list}[0];
        if($org && $org =~ /^(.+?),.+/){
            $org = $1;
        }
    }

    #netblockowner
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[2]/td[4]','list[]' => 'TEXT';
    };
    eval {$result = $scraper->scrape($uri)};
    if($result->{list}[0]){
        $netblockowner = $result->{list}[0];
    }

    #nameserver
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[4]/td[4]','list[]' => 'TEXT';
    };
    eval {$result = $scraper->scrape($uri)};
    if($result->{list}[0]){
        $nameserver = $result->{list}[0];
    }

    #dnsadmin
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[5]/td[4]','list[]' => 'TEXT';
    };
    eval {$result = $scraper->scrape($uri)};
    if($result->{list}[0]){
        $dnsadmin = $result->{list}[0];
    }

    #nameserver_org
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[7]/td[4]','list[]' => 'TEXT';
    };
    eval {$result = $scraper->scrape($uri)};
    if($result->{list}[0]){
        $nameserver_org = $result->{list}[0];
        if($nameserver_org && $nameserver_org =~ /^(.+?),.+/){
            $nameserver_org = $1;
        }
    }

    #domain
    $scraper = scraper {
        process '/html/body/div[3]/div[2]/table[1]/tr[2]/td[2]','domain' => 'HTML';
    };
    eval {$result = $scraper->scrape($uri)};
#    if($@){
#       $domain = $@;
#    }
    if($result->{domain}){
        $domain = $result->{domain};
    }

    return($org,$netblockowner,$nameserver,$dnsadmin,$nameserver_org,$domain);

}


sub host2as{
    # DNSを参照して、ホスト名からIPを求める
    my $host = $_[0];
    my ($count_addr,$company_name,$as);
    my $addr;
    my @addr;
    my $query;
    my $cname = "<BR>";

    # ホスト名の文字列確認。www.aaa.jpや100.100.100.100はokだが、wwwのようなshortホスト名はNG
    if($host =~ /\./){
        my $res2 = Net::DNS::Resolver->new;
        #ホスト名のIPアドレスを取得（DNS Aレコード）


        if($host =~ /\d+\.\d+\.\d+\.\d+/){
            chomp($host);
            $addr = $host;
            ($company_name,$as) = &whois($host); # 事業者名、AS番号
            $count_addr = 1; # IPアドレス カウント数
        }
        else{
            ($addr,$count_addr,$company_name,$as) = &dns($host);
        }
        if($query = $res2->search($host, 'CNAME')){

            @addr = map {$_->cname."\n"} grep($_->type eq 'CNAME', $query->answer);
            if($addr[0]){
                chomp($addr[0]);
                $cname = $addr[0];
            }
        }
    }
    return($addr,$count_addr,$company_name,$as,$cname);
}

sub dns{
    my $host = $_[0];
    my $query;
    my @addr;
    my ($company_name,$as);
    my $count_addr;
    my $res2 = Net::DNS::Resolver->new;
  LABEL1:

    if($query = $res2->search($host, 'A')){
            # IPアドレス(Aレコード)を配列(@addr)に格納。IPアドレス複数ある場合を想定
	@addr = map {$_->address."\n"} grep($_->type eq 'A', $query->answer);
            # 1番目のIPアドレスに対してwhoisにて事業者名、AS番号を取得。複数IPアドレス の場合でもASは同じと仮定

	if($addr[0] =~ /\d+\.\d+\.\d+\.\d+/){
	    chomp($addr[0]);
	    ($company_name,$as) = &whois($addr[0]); # 事業者名、AS番号
	    $count_addr = @addr; # IPアドレス カウント数
	}
	elsif(chomp($addr[0])){
	    goto LABEL1;
	}
    }

    return($addr[0],$count_addr,$company_name,$as);
}

sub whois{
    # JPIRRのwhoisより、IP情報からASを求める
    # 実際には「whois -h jpirr.nic.ad.jp <ip_addr>」を実行し、outputを利用
    my $addr = $_[0];
#    my $whois_out = `/usr/bin/whois -h whois.radb.net $addr`;
#    my $whois_out = `/usr/bin/whois -h jpirr.nic.ad.jp $addr`; # whoisサーバをRADBからJPIRRに変更。情報の信頼性向上
    my $whois_out = `/usr/bin/curl http://jpirr.nic.ad.jp/cgi-bin/search-object.pl?param=$addr`; # whoisサーバをRADBからJPIRRに変更。情報の信頼性向上

    my ($company_name,$as);

    if($whois_out =~ /descr\:\s+(.+)\n(.*\n)*origin\:\s+(\w+)\n/m){
        $company_name = $1; # 事業者名
        $as = $3;           # AS番号
    }
    return($company_name,$as);
}


1;
