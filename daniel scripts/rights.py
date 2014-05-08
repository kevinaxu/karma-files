########## ObjectUri ##########
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## ObjectRightUri ##########
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID + "/objectRight";
return "";
########## END ObjectRightUri END ##########

########## RightTypeUri ##########
import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
  
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/thesauri/object_rights/" + urify(getValue("ObjRightsType"));
return "";
########## END RightTypeUri END ##########

########## RightTypeThes ##########
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/thesauri/object_rights/";
return "";
########## END RightTypeThes END ##########

########## RightActor ##########
objectID = getValue("ObjectID")
if int(objectID) > 0 and !re.search('(unknown)|(public domain)', getValue("ObjRightsType")):
	return "http://collection.britishart.yale.edu/id/thesauri/object_rights/";
return "";
########## END RightTypeThes END ##########







	