/* ElectrodeTest:    1 = Yes     0 = No  */
UPDATE AcqSettings  SET Value = '0'        WHERE Setting = 'ElectrodeTest';

/* Electrode test settings: */
UPDATE AcqSettings  SET Value = '0.001000' WHERE Setting = 'ElectrodeTestCurrentAmpere';
UPDATE AcqSettings  SET Value = '600000.0' WHERE Setting = 'ElectrodeResistanceBadLimitHighOhm';
UPDATE AcqSettings  SET Value = '600000.0' WHERE Setting = 'ElectrodeResistanceBadLimitLowOhm';

/* MeasureMode:   1 = RES,IP   2 = RES   3 = SP    */
UPDATE AcqSettings  SET Value = '2'        WHERE Setting = 'MeasureMode';

/* Measure settings    */
UPDATE AcqSettings  SET Value = '0.2'      WHERE Setting = 'SP_TimeSec';
UPDATE AcqSettings  SET Value = '1.7'      WHERE Setting = 'Acq_DelaySec';
UPDATE AcqSettings  SET Value = '0.3'      WHERE Setting = 'Acq_TimeSec';
UPDATE AcqSettings  SET Value = '0.5000'   WHERE Setting = 'CurrentLimitHighAmpere';
UPDATE AcqSettings  SET Value = '0.0010'   WHERE Setting = 'CurrentLimitLowAmpere';
UPDATE AcqSettings  SET Value = '2'        WHERE Setting = 'StackLimitsHigh';
UPDATE AcqSettings  SET Value = '2'        WHERE Setting = 'StackLimitsLow';

/* Fullwaveform:    1 = Yes     0 = No  */   
UPDATE AcqSettings  SET Value = '1'        WHERE Setting = 'Fullwaveform';

