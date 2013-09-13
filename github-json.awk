function join(array, sep, start, end)
{
	if (sep == "") sep = " "
	else if (sep == SUBSEP) # magic value
		sep = ""

	result = array[start]
	for (i = start + 1; i <= end; i++)
	{
		if(array[i])
		result = result sep array[i]
	}

	return result
}
/^\["items",[0-9]+,"/{

	klen=split($1,keys,/,/)
	repo="000"keys[2]

	key = join(keys, "/", 3, klen)
	gsub(/[\[\]\"]/, "", key)

	value=$2
	for(i=3; i <= NF; i++)
		value = value FS $i

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
		# print "+----------------------------------------------"
		# print "| Repo# ", r;
		print "| Project: ", data[r,"name"];
		print "| User: ", data[r,"owner/login"];

		if( data[r,"language"] )
		print "| Language: ", data[r,"language"];
		print "| URL: ", data[r,"html_url"];
		if( data[r,"description"] )
		{
			print "| About: ", data[r,"description"];
		}

		print "+----------------------------------------------"
	}
}
