########## ObjectUri ##########
objectID = getValue("objectID")
if re.search(getValue("thesxreftype"), "subjectActor") and int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## SubjectActorUri ##########
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
if re.search('subjectActor', getValue("thesxreftype")) and int(getValue("objectID")) > 0:
	if re.search(source, "ULAN", re.IGNORECASE):
		uri = "http://vocab.getty.edu/ulan/" + getValue("TMstID")
    else:
		uri = "http://collection.britishart.yale.edu/id/thesauri/person-institution/" + urify(getValue("Term"))

return uri
########## END SubjectActorUri END ##########

########## SubjectActorInScheme ##########
#
import re

source = getValue("UCTS")
uri = ""
if re.search(getValue("thesxreftype"), "subjectActor") and int(getValue("objectID")) > 0:
 if re.search(source, "ULAN", re.IGNORECASE):
  uri = "http://vocab.getty.edu/ulan/"
 else:
  uri = "http://collection.britishart.yale.edu/id/thesauri/person-institution/"

return uri
########## END SubjectActorInScheme END ##########

########## SubjectActorLabel ##########
import re
if re.search(getValue("thesxreftype"), "subjectActor"):
    return getValue("Term")
########## END SubjectActorLabel END ##########






	