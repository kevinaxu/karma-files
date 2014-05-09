########## ObjectUri ##########
objectID = getValue("ObjectID")
if int(objectID) > 0 and re.search("Collective title", getValue("TitleType")):
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## TitleUri ##########
import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
  
objectID = getValue("ObjectID")
if int(objectID) > 0 and re.search("Collective title", getValue("TitleType")):
    return "http://collection.britishart.yale.edu/id/object/"+objectID+"/series/"+urify(getValue("Title"))
return ""
########## END TitleUri END ##########