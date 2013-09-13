function max(a, b){
		if(a > b)
			return a
		else
			return b
}

function pad(str, len){
		l=length(str)
		while(l < len){
			str=str"."
			l++
		}

		return str".."
}

function trim(str){
	gsub(/^\s+|\s+$/g,"",str)
	return str
}

{
	r=trim($(NF-1))
	proj=pad(r,18)
	user=$(NF-2)

	print proj""user"/"r
}
