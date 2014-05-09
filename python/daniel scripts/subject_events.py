########## ObjectUri ##########
objectID = getValue("objectID")
if re.search(getValue("thesxreftype"), "subjectActor") and int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## SubjectPlaceUri ##########
import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str

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

########## SubjectPlaceLabel ##########
import re
if re.search(getValue("thesxreftype"), "subjectPlace"):
    return getValue("Term")
########## END SubjectPlaceLabel END ##########

########## CoordUri ##########
import re
if re.search(getValue("thesxreftype"), "subjectPlace"):
    return getValue("SubjectPlaceUri") + "/coordinates"
########## END CoordUri END ##########

########## CoordInScheme ##########
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
########## END CoordInScheme END ##########

########## LocUri ##########
import re
if re.search(getValue("thesxreftype"), "subjectPlace"):
    return getValue("SubjectPlaceUri") + "/location"
########## END LocUri END ##########

########## LocInScheme ##########
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
########## END LocInScheme END ##########

########## LocPointUri ##########
import re
if re.search(getValue("thesxreftype"), "subjectPlace"):
    return getValue("SubjectPlaceUri") + "/location/point"
########## END LocPointUri END ##########




	