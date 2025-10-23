# Aarogya_Catalysts
The Smart IoT-Based Medicine Dispenser Machine automates medicine distribution using an ESP32, sensors, RTC, and a mobile app. It securely dispenses the right medicine at the right time, ensuring accuracy, reducing human error, and improving hospital and patient care efficiency.

1.	Problem Statement:
In hospitals, especially in wards with multiple patients, nurses and caretakers face significant challenges in accurately managing and dispensing medicines as per each patient’s prescription and schedule.
Manual tracking often leads to missed doses, wrong timings, or medication errors, directly affecting patient recovery and hospital efficiency. Moreover, during high workload periods, ensuring timely delivery for every patient becomes nearly impossible without a digital aid.

2.	Proposed Solution: 	
Care Catalysts present the “Smart IoT-Based Medicine Dispenser Machine”, a compact, automated system designed to simplify and secure medicine distribution in healthcare environments.
The device consists of five servo-controlled slots for storing different types of medicines. Using a personalized mobile application (built with Flutter), verified doctors can assign medication schedules to multiple patients. The machine, powered by an ESP32 microcontroller and operating over a secure HTTPS protocol, automatically dispenses the right medicine at the right time.

Key Features:
•	Real-Time Scheduling: Doctor assigns medicine doses remotely via the app.
•	Automated Dispensing: Servos release medicine when the nurse’s hand is detected by an ultrasonic sensor.
•	Notification System: Buzzer, LCD, and speaker alerts show which patient’s medicine is due.
•	Touch Verification: Nurse authentication through touch sensor.
•	Safety Monitoring: Integrated smoke and temperature sensors trigger emergency alerts.
•	Accurate Timekeeping: Real-Time Clock (RTC) ensures exact medicine timings.

3.	Practicality and Impact: 
This system reduces human error, ensures timely delivery of medicine, and relieves nursing staff from repetitive scheduling burdens.
Its modular, low-cost design makes it ideal for hospital wards, elderly care homes, and clinics. By using secure HTTPS communication, the system ensures data integrity, patient privacy, and authorized control by healthcare professionals.
Ultimately, this innovation bridges the gap between IoT technology and healthcare, promoting precision, safety, and efficiency — truly living up to the spirit of our team name, Care Catalyst: Accelerating Smarter Healthcare.
