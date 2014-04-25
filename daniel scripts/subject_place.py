########## ObjectUri ##########
objectID = getValue("objectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## SubjectPlaceUri ##########
import re

def urify(str):
    return re.sub(r'\s+', '-', str.lower())

source = getValue("UCTS")
uri = ""
if re.search('subjectPlace', getValue("thesxreftype")) and int(getValue("objectID")) > 0:
	if re.search(source, "TGN", re.IGNORECASE):
		uri = "http://vocab.getty.edu/tgn/" + getValue("TMstID")
    else:
		uri = "http://collection.britishart.yale.edu/id/thesauri/place/" + urify(getValue("Term"))

return uri
########## END SubjectPlaceUri END ##########

########## SubjectPlaceInScheme ##########
#
import re

source = getValue("UCTS")
uri = ""
if re.search(getValue("thesxreftype"), "subjectPlace") and int(getValue("objectID")) > 0:
 if re.search(source, "TGN", re.IGNORECASE):
  uri = "http://vocab.getty.edu/tgn/"
 else:
  uri = "http://collection.britishart.yale.edu/id/thesauri/place/"

return uri
########## END SubjectPlaceInScheme END ##########

########## CoordUri ##########
import re
if re.search(getValue("thesxreftype"), "subjectPlace"):
    return getValue("SubjectPlaceUri") + "/coordinates"
########## END CoordUri END ##########
	
	
