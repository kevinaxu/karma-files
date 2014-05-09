########## TitleThesInscheme ##########
import re
if not re.search("Collective title", getValue("TitleType")):
    return "http://collection.britishart.yale.edu/id/thesauri/title/"
return ""
########## END TitleThesInscheme END ##########

########## TitleTypeUri ##########
import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
  
if not re.search("Collective title", getValue("TitleType")):
    return "http://collection.britishart.yale.edu/id/thesauri/title/"+urify(getValue("TitleType"))
return ""
########## END TitleTypeUri END ##########