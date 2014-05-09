#############################
# Inscriptions 
# File: Objects.csv
# Kevin Xu
# 4/22/14
#############################

## ObjectURI
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID
return ""

## Signed and Dated Type
return "http://collection.britishart.yale.edu/id/thesauri/inscription/signed_and_dated/"

## Signed and Dated Type Label
return "Signed and Dated"

# Signed URI 
# 
# ALT: 
# objectID = getValue("ObjectID")
# if int(objectID) > 0: 
# 	return getValue("ObjectURI") + "/inscription/3"
# return ""
return "http://collection.britishart.yale.edu/id/" + getValue("ObjectID") + "/inscription/3"

## Inscription URI
return "http://collection.britishart.yale.edu/id/" + getValue("ObjectID") + "/inscription/1"

# Inscription Type
return "http://collection.britishart.yale.edu/id/thesauri/inscription/inscription/"

# Inscription Type Label
return "Inscription"

# Inscription inScheme
return "http://collection.britishart.yale.edu/id/thesauri/inscription/"

# Lettering URI
return "http://collection.britishart.yale.edu/id/" + getValue("ObjectID") + "/inscription/4"

# Lettering Type
return "http://collection.britishart.yale.edu/id/thesauri/inscription/lettering/"

# Lettering Type Label
return "Lettering"

# Markings URI
return "http://collection.britishart.yale.edu/id/" + getValue("ObjectID") + "/inscription/2"

# Marking Type URI
return "http://collection.britishart.yale.edu/id/thesauri/inscription/marks/"

# Marking Type Label
return "Marks"









