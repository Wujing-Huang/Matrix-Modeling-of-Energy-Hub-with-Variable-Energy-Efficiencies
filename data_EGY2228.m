% Data for hourly energy demand and hourly electricity and gas prices
% Reference: article published on Energy 34 (2009) 261?273
% Title: Matrix modelling of small-scale trigeneration systems and application to operational optimization
% Authors: Gianfranco Chicco (gianfranco.chicco@polito.it) and Pierluigi Mancarella (pierluigi.mancarella@unimelb.edu.au)

% Demand (hourly energy)

% winter period (first column: electricity; second column: heat; third column: cooling)
demand_winter=[
 96.844	303.5	0
 97.456	303.5	0
 97.859	303.5	0
 92.723	303.5	0
 94.040	303.5	0
111.940	607.5	0
162.010	720.0	0
189.898	832.5	0
203.570	832.5	0
193.660	832.5	0
196.160	832.5	0
201.069	814.5	0
188.328	796.5	0
191.097	789.5	0
183.694	771.5	0
179.225	742.5	0
179.499	742.5	0
191.099	742.5	0
205.065	742.5	0
205.443	742.5	0
181.196	607.5	0
151.226	607.5	0
133.989	303.5	0
118.683	303.5	0
];

% intermediate period (first column: electricity; second column: heat; third column: cooling)
demand_intermediate=[
 87.1596    168.5	 0
 87.7104    168.5	 0
 88.0731    168.5	 0
 83.4507    168.5	 0
 84.6360    168.5	 0
100.7460	337.5	 0
145.8090	450.0    0
170.9082	562.5	 0
183.2130	562.5	14
174.2940	562.5	27
176.5440	562.5	42
180.9621	544.5	69
169.4952	526.5	85
171.9873	519.5	70
165.3246	501.5	44
161.3025	472.5	29
161.5491	472.5	15
171.9891	472.5	 3
184.5585	472.5	 0
184.8987	472.5	 0
163.0764	337.5	 0
136.1034	337.5	 0
120.5901	168.5	 0
106.8147	168.5	 0
];

% summer period (first column: electricity; second column: heat; third column: cooling)
demand_summer=[
 77.4752	  0	  0
 77.9648	  0	  0
 78.2872	  0	  0
 74.1784	  0	  0
 70.2320	  0	  0
 85.5520	  0	  0
124.6080	112	 24
151.9184	225	 76
162.8560	225	132
154.9280	225	190
156.9280	225	288
160.8552	207	344
150.6624	189	360
152.8776	182	336
146.9552	164	278
133.3800	135	180
133.5992	135	118
142.8792	135	 64
160.0520	135	 22
164.3544	135	  4
144.9568	  0	  0
120.9808	  0	  0
107.1912	  0	  0
 94.9464	  0	  0
];

% Electricity and gas hourly prices (euros/MWh)

% winter season (first column: electricity; second column: gas)
prices_winter=[
 50.23	20
 42.13	20
 37.64	20
 37.25	20
 37.19	20
 37.44	20
 51.25	20
 71.66	20
106.50	20
107.61	20
106.65	20
106.65	20
 95.65	20
 82.67	20
104.67	20
105.67	20
115.65	20
121.65	20
106.61	20
 84.65	20
 78.65	20
 51.69	20
 50.60	20
 43.61	20
];

% intermediate period (first column: electricity; second column: gas)
prices_intermediate=[
 41.11	20
 22.55	20
 22.44	20
 22.44	20
 22.44	20
 35.26	20
 41.17	20
 61.94	20
105.45	20
120.00	20
120.00	20
110.50	20
 75.20	20
 75.15	20
 84.15	20
 84.15	20
 84.03	20
 84.13	20
119.36	20
 92.14	20
 70.18	20
 61.60	20
 41.14	20
 41.17	20
];

% summer period (first column: electricity; second column: gas)
prices_summer=[
 30.44	20
 22.55	20
 22.54	20
 22.54	20
 30.55	20
 35.49	20
 45.75	20
 74.20	20
100.21	20
108.27	20
108.67	20
 76.14	20
 69.26	20
 76.28	20
 84.54	20
 98.80	20
 82.78	20
 69.07	20
 60.12	20
 62.93	20
 65.09	20
 49.25	20
 45.40	20
 35.11	20
];

