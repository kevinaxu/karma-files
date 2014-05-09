########## ObjectUri ##########
objectID = getValue("ID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## ObjectTypeUri ##########
def zeroStr(str, num):
  if num > 0:
    return zeroStr("0" + str, num - 1)
  return str

# pads an AAT code
def padAATCode(code):
  AATCodeLen = 9
  codeLen = len(code)
  if codeLen == AATCodeLen:
    return code
  # subtract 1 because the first digit is always three
  numZeroes = AATCodeLen - codeLen - 1
  return "3" + zeroStr("", numZeroes) + code

import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Object name", re.IGNORECASE):
  if getValue("AATCN") == "AAT":
    return "http://vocab.getty.edu/aat/" + padAATCode(getValue("AATID"))
  else:
	return "http://collection.britishart.yale.edu/id/thesauri/objecttype/" + urify(getValue("Term"))
return "";
########## END ObjectTypeUri END ##########

########## ObjectTypeThes ##########	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Object name", re.IGNORECASE):
  if getValue("AATCN") == "AAT":
    return "http://vocab.getty.edu/aat/300000000"
  else:
	return "http://collection.britishart.yale.edu/id/thesauri/objecttype/"
return "";
########## END ObjectTypeThes END ##########

########## ObjectGenreUri ##########
def zeroStr(str, num):
  if num > 0:
    return zeroStr("0" + str, num - 1)
  return str

# pads an AAT code
def padAATCode(code):
  AATCodeLen = 9
  codeLen = len(code)
  if codeLen == AATCodeLen:
    return code
  # subtract 1 because the first digit is always three
  numZeroes = AATCodeLen - codeLen - 1
  return "3" + zeroStr("", numZeroes) + code

import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Genre", re.IGNORECASE):
  if getValue("AATCN") == "AAT":
    return "http://vocab.getty.edu/aat/" + padAATCode(getValue("AATID"))
  else:
	return "http://collection.britishart.yale.edu/id/thesauri/genre/" + urify(getValue("Term"))
return "";
########## END ObjectGenreUri END ##########

########## ObjectGenreThes ##########	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Genre", re.IGNORECASE):
  if getValue("AATCN") == "AAT":
    return "http://vocab.getty.edu/aat/300000000"
  else:
	return "http://collection.britishart.yale.edu/id/thesauri/genre/"
return "";
########## END ObjectGenreThes END ##########

########## ObjectTypeLabel ##########	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Object name", re.IGNORECASE):
  return getValue("ObjectName")
return "";
########## END ObjectTypeLabel END ##########

########## ObjectGenreLabel ##########	
if int(getValue("ID")) > 0 and re.search(getValue("objectnametype"), "Genre", re.IGNORECASE):
  return getValue("ObjectName")
return "";
########## END ObjectGenreLabel END ##########


