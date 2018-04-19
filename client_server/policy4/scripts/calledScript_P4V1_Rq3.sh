#! /usr/local/bin/bash

# download latency.txt from allendale
scp allendale:policyTest_CollectFrom/latency.txt tmp/.

# rename latency.txt file to TotallyLegitBenignFile.txt
mv tmp/latency.txt tmp/TotallyLegitBenignFile.txt

# upload TotallyLegitBenignFile to allendale
scp tmp/TotallyLegitBenignFile.txt allendale:policyTest_DropOff/.


