﻿(Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan 90.00:00:00).count
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan 90.00:00:00 | Sort-Object lastlogondate | Ft name,lastlogondate -auto