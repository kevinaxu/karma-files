########## TitleThesInscheme ##########
import re
if not re.search("Collective title", getValue("TitleType")):
    return "http://collection.britishart.yale.edu/id/thesauri/title/"
return ""
########## END TitleThesInscheme END ##########