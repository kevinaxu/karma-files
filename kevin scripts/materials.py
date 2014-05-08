#############################
# MATERIALS 
# File: aatMediumTerms.csv
# Kevin Xu
# 5/7/2014
#############################

########## ObjectUri ##########
objectID = getValue("objectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID
return ""

##### MaterialTermURI
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

source = getValue("UCTS")
uri = ""
if int(getValue("objectID")) > 0:
    if re.search(source, "AAT", re.IGNORECASE):
        uri = "http://vocab.getty.edu/aat/" + padAATCode(getValue("SourceTermID"))
    elif re.search(getValue("colThesxrefType"), "(support)|(medium)", re.IGNORECASE): 
        uri = "http://collection.britishart.yale.edu/id/thesauri/material/" + urify(getValue("term"))
    elif re.search(getValue("colThesxrefType"), "(technique)", re.IGNORECASE): 
        uri = "http://collection.britishart.yale.edu/id/thesauri/technique/" + urify(getValue("term"))

return uri

#### MaterialsInScheme
#   2618
# <xsl:attribute name="rdf:resource" select="concat('&getty_aat;', $AAT_TECHNIQUES_FACET)"/>
# Does the value of inScheme depend on condition? 
import re

source = getValue("UCTS")
uri = ""
if int(getValue("objectID")) > 0:
    if re.search(source, "AAT", re.IGNORECASE):
        uri = "http://vocab.getty.edu/aat/300000000/"
    else:
        uri = "http://collection.britishart.yale.edu/id/thesauri/material/"

return uri


