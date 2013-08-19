/^\["repositories",[0-9]+,"/{

	split($1,keys,/,/)
	key=keys[3]
	repo="000"keys[2]
	key=substr(key,2)
	len=length(key)
	key=substr(key, 1, len-2)

	value=$2
	where=match(value,/^"/)
	if(where > 0)
	{
		len=length(value)
		value=substr(value, 2, len-2)
	}

	if(!repos[repo])
	{
		repos[repo]=1;
	}

	data[repo,key]=value
}
END{
	for (r in repos)
	{
		#print "+----------------------------------------------"
		print "| Repo# ", r;
		print "| Project: ", data[r,"name"];
		print "| User: ", data[r,"username"];
		if( data[r,"username"] != data[r,"owner"])
		{
			print "| Owner: ", data[r,"owner"];
		}

		if( data[r,"language"] )
		print "| Language: ", data[r,"language"];
		print "| URL: ", data[r,"url"];
		print "| About: ", data[r,"description"];
		print "+----------------------------------------------"
	}
}
