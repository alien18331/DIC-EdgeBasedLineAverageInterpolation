wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/yutongshen/HW5/work/CTE_pre.fsdb}
wvRestoreSignal -win $_nWave1 "/home/yutongshen/HW5/work/CTE.rc" \
           -overWriteAutoAlias on
wvResizeWindow -win $_nWave1 98 130 1162 621
wvSetCursor -win $_nWave1 45311.373584 -snap {("G1" 12)}
wvSelectSignal -win $_nWave1 {( "G1" 14 )} 
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvExpandBus -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvScrollUp -win $_nWave1 6
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvCollapseBus -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvExpandBus -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvScrollUp -win $_nWave1 9
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvCollapseBus -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G2" 0)}
