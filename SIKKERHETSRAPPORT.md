# Sikkerhetsrapport_v2

![](https://slsa.dev/spec/v1.2/images/supply-chain-threats.svg)

# 1. Kilde

## A - Produsent

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Produsent utnytter sin legitime byggekjede til å produsere et artefakt som med hensikt skader konsumenten | Ingen tekniske tiltak |  |

## B1 - Uautorisert endring av kildekode

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Utvikler med skrivetilgang pusher ondsinnet kode direkte til main | Branch protection med
krav om PR før merge | Ondsinnet kode kan fortsatt godkjennes i review |
| Angriper med flere brukerkontoer godkjenner sine egen endring | Krav om godkjenning fra kodeeier (CODEOWNERS), minimum to reviewers, og forfatter skal ikke kunne godkjenne egen PR | To personer som samarbeider om angrepet |
| Automasjonskonto eller app med bypass-rettigheter sender inn endringer uten godkjenning | Gi bypass kun til navngitte apper og begrens hva de får skrive | Kompromittering av appen eller appens credentials |
| Aktør pusher til en branch som ikke dekkes av rulesettets mønster, og merger derfra | Rulesets dekker alle brancher som kan nå produksjon |  |
| Administrator skrur av beskyttelse for å legge inn ondsinnet kode | Revisjonslogg på endringer i repo-innstillinger, med varsling til sikkerhetsansvarlig | Administrator kan fortsatt skru av beskyttelsen |
| Aktør legger inn hemmelighet eller kjent skadevare i en commit | Skann alle commits for hemmeligheter og kjent skadevare, og blokker push ved funn |  |
| Aktør tar kontroll over en utviklers maskin eller konto, og godkjenner eller pusher kode som den personen | Ikke adressert av SLSA. 
Kan benytte fysiske signeringsnøkler som tiltak. | Signering med stjålet signeringsnøkkel |

## B2 - Omgå endringsprosess

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør omskriver branch-historikken for å skjule at ondsinnet kode ble lagt inn | Branch protection for å blokkere force-push.
Blokker sletting av beskyttede brancher. |  |
| Aktør flytter en versjonstag til å peke på en ondsinnet versjon, slik at bygg som refererer taggen henter ondsinnet kode | Gjør versjonstagger uforanderlige, så de ikke kan flyttes eller slettes etter at de er opprettet **eller** bruk en hash for å referere til eksakt versjon.
 | Aktør med rettigheter oppretter nye tagger |
| Endring merges uten at påkrevde sjekker har kjørt | Påkrevde status-sjekker i branch protection, inkludert bygg, tester og sårbarhetsskanning | Ondsinnet kode som passerer sjekkene |
| Kode endres etter at pull request er godkjent, men før merge  | Godkjent pull request forkastes automatisk ved nye commits (”dismiss stale pull request approvals”) | Endringer som godkjennes på nytt uten gjennomgang |
| Aktør legger inn en ondsinnet commit og en commit som fjerner den igjen, slik at nettoendringen ser tom ut, men koden finnes i historikken og distribueres til alle som kloner repoet | Squash merge  |  |

## B3 - Undergrave kodegjennomgang

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| To autoriserte utviklere samarbeider om å godkjenne ondsinnet kode | Ingen teknisk kontroll | Alt |
| Aktør utformer kodeendringen slik at revieweren ikke oppdager det ondsinnede (obfuskert kode, stor diff) | Krav om små pull requests.
 | Godt skjult kode |
| Reviewer godkjenner kode uten å lese endringen | Ingen teknisk kontroll | Alt |

## B4 - Forfalske endringsmetadata

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør setter en annen utviklers navn som forfatter på en commit, eller daterer den tilbake i tid | Signerte commits gjør det mulig å verifisere at committen er signert av en forventet kryptografisk identitet | Utnytte andres signatur til å pushe kode, f.eks. via remote access |

## C - Kildekodesystem

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Plattformadministrator bruker sine privilegier til å omgå sikkerhetstiltak og legge inn ondsinnet kode | Begrens antall administratorer. 
Revisjonslogg med varsling.
 | Administratoren kan fortsatt omgå kontrollene. Tiltaket gir sporbarhet men ikke hindring |
| Aktør utnytter sårbarhet i selve versjonskontrollplattformen til å omgå sikkerhetstiltak | Ikke adressert av SLSA. Følg leverandørens sikkerhetsvarsler |  |

# 2. Bygging

## D - Eksterne byggeparametere

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør bygger fra en uoffisiell fork av kodebasen og publiserer resultatet som det offisielle artefaktet | Verifikator krever at kilden i provenance viser forventet repo |  |
| Aktør bygger fra en branch eller tag som ikke er den offisielle | Verifikator krever at kildereferansen i provenance matcher  |  |
| Aktør endrer byggestegene slik at bygget gjør noe annet enn tiltenkt | Byggeoppskriften ligger i et sentral eid repo med gjenbrukbare workflows. Her har ikke app-utviklere skrivetilgang. |  |
| Aktør sender inn byggeparametere (flagg, miljøvariabler, build args) som endrer resultatet  | Verifikator avviser bygg som er kjørt med andre parametere enn de forventede |  |
| Aktør legger inn et byggesteg som endrer kildekoden etter at den er hentet, slik at artefaktet bygges fra annen kode | Legg byggeoppskriften i et repo utviklere ikke kan skrive til, slik at steg mellom henting og bygging ikke kan legges inn |  |
| Aktør åpner pull request fra en fork i et offentlig repo, og byggekjeden kjører angriperens kode | Krev manuell godkjenning før byggekjeden kjører for eksterne bidragsytere.
Deaktiver installasjonsskript, og ikke lagre credentials til disk under bygget | Kode som kjøres etter at builden er godkjent |
| Aktør legger til et ondsinnet byggesteg  |  |  |

## E - Byggeprosessen

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Byggejobben skriver selv innholdet i provenance, og oppgir et annet kilderepo enn det den faktisk bygde fra  | Velg en byggeplattform der kontrollplanet generer og signerer all informasjon i provenance | Krever tillit til byggeplattform og at ingen sårbarheter utnyttes |
| Byggejobben bryter ut av containeren sin, leser signeringsnøkkelen fra vertsmaskinen, og signerer en provenance som lyver om bygget | Velg en byggeplattform der hvert bygg kjører isolert i et kortlevd miljø, hvor signeringsnøkkelen aldri er tilgjengelig i byggemiljøet | Utbrudd via en sårbarhet i plattformens isolasjonsmekanisme |
| Aktør får eierrettigheter på byggeprosjektet og bruker en debug- eller konfigurasjonsmulighet til å påvirke bygg mens det pågår  | Velg en plattform der ingen kan koble seg på eller endre et bygg mens det kjører |  |
| Aktør starter et ondsinnet bygg som venter på at et legitimt bygg starter på samme maskin, og bytter ut kildefilene mens det pågår | Velg en byggeplattform der hvert bygg kjører i en egen isolert virtuell maskin |  |
| Aktør kjører et bygg som erstatter et verktøy på maskinen med en manipulert versjon, og venter på at neste bygg bruker den | Velg en byggeplattform der hvert bygg starter fra et rent maskinbilde |  |
| Aktør legger inn et steg som leser miljøvariabler og filsystemet i byggemiljøet og sender det ut, for å få tak i tokens og nøkler | Bruk kortlevde hemmeligheter som utstedes til den enkelte jobben og utløper når den er ferdig | Misbruk innenfor jobbens levetid |
| Aktør legger noe manipulert i byggecachen, og et senere legitimt bygg henter det derfra i stedet for å bygge på nytt | Ikke del cache mellom bygg som ikke stoler på hverandre
Eventuelt ikke bruk cache | Hvis cache: vanlige CI-plattformer deler cache på tvers av brancher 

 |
| Aktør får administratortilgang til byggeplattformen og kan påvirke alle bygg og signering | Ikke adressert av SLSA |  |

## F - Publisering av artefaktet

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør bygger artefaktet i sin egen pipeline og laster det opp under det offisielle navnet | Konfigurer verifikatoren til å kreve provenance der byggeren matcher en forventet identitet, og håndhev det ved utrulling | Bruk av artefaktet i miljøer der verifisering ikke kjører |
| Aktør laster opp et ondsinnet artefakt uten attestasjon | Konfigurer verifikatoren til å kreve attestasjon før artefaktet aksepteres |  |
| Aktør laster ned et legitimt artefakt, endrer innholdet, og laster det opp igjen med den opprinnelige attestasjonen | Konfigurer verifikatoren til å sammenligne artefaktets hash mot “subject” i attestasjonen |  |
| Aktør bygger et ondsinnet artefakt og redigerer feltet for kilderepo i attestasjonen, slik at den ser ut til å komme fra riktig sted | Konfigurer verifikatoren til å kreve gyldig kryptografisk signatur, sjekket opp mot verifikatorens offentlige nøkkel | Aktør som kan bytte ut den offentlige nøkkelen (se kapittel 6) |

## G - Distribusjonskanal

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør med skrivetilgang til registeret erstatter et publisert artefakt med et han har selv bygget | Verifiser provenance mot forventet repo og workflow ved utrulling også | Bruk i miljøer der verifisering er slått av  |
| Aktør utsteder sin egen verifiseringsattestasjon for et ondsinnet artefakt, og konsumenten deployer det uten å sjekke provenance | Sett opp hvilke utstedere man stoler på, med deres offentlige nøkler. Avvis attestasjoner signert av andre | Kompromittert nøkkel hos en utsteder |
| Aktør erstatter artefaktet i registeret med et ondsinnet, og sletter den opprinnelige attestasjonen så det ikke finnes noe å sammenligne mot | Konfigurer verifikatoren til å avvise artefakter som mangler attestasjon | Artefakter som er unntatt fra sikkerhetspolicien |
| Aktør publiserer et ondsinnet artefakt lovlig under eget navn og får en ekte attestasjon. Deretter erstatter han det offisielle artefaktet og dets attestasjon med sitt eget par. Begge er ekte, men beskriver en annen pakke | Referer artefakter ved digest. Det kontrollerer at attestasjonen gjelder artefaktet som ble etterspurt, ikke bare det som ble levert |  |
| Aktør bytter ut en publisert fil i et register som adresserer på navn og versjon, og lar attestasjonen ligge urørt | Sammenlign artefaktets hash mot “subject” i attestasjonen før bruk |  |
| Aktør bygger et ondsinnet artefakt og redigerer attestasjonen så feltene ser riktige ut | Verifiser signaturen mot verifikatorens offentlige nøkkel | Aktør kan bytte ut nøkkelen (se kap 6) |

# 3. Bruk

## H - Pakkevalg

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør registrerer et pakkenavn i et offentlig register som er identisk med et navn brukt i det interne registeret, med et høyere versjonsnummer. En feilkonfigurert klient henter den offentlige versjonen  | Konfigurer pakkehåndtereren slik at interne pakkenavn alltid går mot det interne registeret |  |
| Aktør registrerer et pakkenavn som ligner på en mye brukt pakke, og venter på at noen henter ved en feil | Bruk låsefil. 
Gjennomgå nye avhengigheter som en egen endring. 
Vurder verktøy som varsler om navnelikhet (typosquatting). |  |

## I - Bruk

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Konsumenten konfigurerer programvaren på en måte som svekker sikkerheten | Ikke adressert av SLSA.  |  |

# 4. Avhengigheter

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Artefaktet bygges med en avhengighet som har en sårbarhet, uten at noen oppdager det før utrulling | Kjør sårbarhetsskanning på både avhengighetstreet og det ferdige artefaktet i byggekjeden, og la funn stoppe bygget.
Slå på automatiske oppdateringsforslag ved sikkerhetsvarsler. | Sårbarheter som ennå ikke er publisert i databasene |
| Aktør kompromitterer et byggeverktøy, slik at det injiserer uønsket kode i artefaktet under bygging | Pinne byggeverktøy til bestemte versjoner med integritetssjekk. 
Referer base-images ved digest og actions ved commit-SHA.
Slå på automatiske oppdateringsforslag så pinningen holdes fersk. | Fortsatt bruk av et kompromittert byggeverktøy som er pinnet, frem til noen oppdaterer pinningen  |
| Aktør kompromitterer en testavhengighet. Den kjører under bygget, før imaget er ferdig, og skriver kode inn i det som pakkes | Kjør tester i en egen jobb uten skrivetilgang til byggets utdata.  |  |
| Aktør legger et installasjonsskript i en pakke. Det kjører automatisk ved installasjon, før noen kode i prosjektet har kjørt | Deaktiver installasjonsskript ved installasjon av avhengigheter |  |

# 5. Tilgjengelighet

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør bygger fra en commit og fjerner den deretter fra repoet, slik at koden bygget kom fra ikke kan granskes i ettertid | Blokker sletting av beskyttede brancher og tagger. | Sletting utført hos plattformleverandøren |
| En avhengighet trekkes tilbake fra registeret, eller registeret er nede, og bygget kan ikke kjøres | Speil avhengigheter i et internt register.
Gjør bygget hermetisk, slik at det ikke henter noe fra nettet under bygging |  |
| Registeret slutter å levere artefaktet, og utrulling stopper | Speil artefakter i eget register |  |
| Registeret slutter å levere attestasjonen. Verifikatoren finner ingenting å verifisere mot og avviser artefaktet | Speil attestasjoner sammen med artefaktene |  |

# 6. Verifisering

Verifikatoren kan være en admission controller i et cluster, et steg i byggekjeden, eller en klient som sjekker før installasjon. Truslene under gjelder alle.

| **Risikoscenarie** | **Tiltak** | **Hva det ikke stopper** |
| --- | --- | --- |
| Aktør legger sin byggeidentitet til verifikatorens liste over aksepterte utstedere, og bygger deretter i sitt eget repo | Legg verifikatorens konfigurasjon under versjonskontroll med branch protection, og krev gjennomgang av to personer ved endring |  |
| Aktør bytter ut den offentlige nøkkelen verifikatoren sjekker signaturer mot, og signerer deretter attestasjoner selv | Se over |  |
| Aktør endrer verifikatorens konfigurasjon direkte i driftsmiljøet, uten å gå veien om versjonskontroll. Endringen finnes ikke som en commit noe sted | Drift konfigurasjonen via GitOps, slik at manuelle endringer overskrives |  |