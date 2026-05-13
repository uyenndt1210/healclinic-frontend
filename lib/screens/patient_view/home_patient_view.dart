import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  State<HomePatientScreen> createState() =>
      _HomePatientScreenState();
}

class _HomePatientScreenState
    extends State<HomePatientScreen> {

  bool isLoading = true;

  Map<String, dynamic>? patientInfo;

  List<dynamic> doctors = [];
  List<dynamic> specialties = [];

  static const String baseUrl =
      'http://10.0.2.2:5257/api';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {

      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/patient/me')),
        http.get(Uri.parse('$baseUrl/doctors')),
        http.get(Uri.parse('$baseUrl/specialties')),
      ]);

      final patientRes = responses[0];
      final doctorRes = responses[1];
      final specialtyRes = responses[2];

      if (patientRes.statusCode == 200) {
        patientInfo = jsonDecode(patientRes.body);
      }

      if (doctorRes.statusCode == 200) {
        doctors = jsonDecode(doctorRes.body);
      }

      if (specialtyRes.statusCode == 200) {
        specialties = jsonDecode(specialtyRes.body);
      }

    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F8FC),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF00AEEF),
        unselectedItemColor: Colors.grey,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch hẹn',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Tin nhắn',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================

              Container(
                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),

                  borderRadius: BorderRadius.only(
                    bottomLeft:
                    Radius.circular(30),
                    bottomRight:
                    Radius.circular(30),
                  ),
                ),

                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 30,
                      backgroundColor:
                      Colors.white,

                      child: Icon(
                        Icons.person,
                        size: 35,
                        color:
                        Color(0xFF00AEEF),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          const Text(
                            'Xin chào',
                            style: TextStyle(
                              color:
                              Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          Text(
                            patientInfo?[
                            'fullName'] ??
                                'Bệnh nhân',

                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= SEARCH =================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: TextField(
                  decoration: InputDecoration(
                    hintText:
                    'Tìm bác sĩ, chuyên khoa...',

                    prefixIcon:
                    const Icon(Icons.search),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                          18),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ================= QUICK ACTION =================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    quickButton(
                      Icons.calendar_today,
                      'Đặt lịch',
                    ),

                    quickButton(
                      Icons.medical_services,
                      'Bác sĩ',
                    ),

                    quickButton(
                      Icons.receipt_long,
                      'Kết quả',
                    ),

                    quickButton(
                      Icons.local_hospital,
                      'Khoa',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ================= SPECIALTY =================

              const Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  'Chuyên khoa',

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 120,

                child: ListView.builder(
                  scrollDirection:
                  Axis.horizontal,

                  itemCount: specialties.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                    specialties[index];

                    return Container(

                      width: 120,

                      margin:
                      const EdgeInsets.only(
                        left: 20,
                      ),

                      padding:
                      const EdgeInsets.all(
                          16),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                            22),

                        boxShadow: [

                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                0.05),

                            blurRadius: 10,
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          const Icon(
                            Icons.local_hospital,
                            size: 36,
                            color:
                            Color(0xFF00AEEF),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            item['specialtyName'] ??
                                '',

                            textAlign:
                            TextAlign.center,

                            maxLines: 2,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // ================= DOCTOR LIST =================

              const Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  'Bác sĩ nổi bật',

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ListView.builder(

                itemCount: doctors.length,

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemBuilder:
                    (context, index) {

                  final doctor =
                  doctors[index];

                  return Container(

                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),

                    padding:
                    const EdgeInsets.all(
                        16),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                          22),

                      boxShadow: [

                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                              0.05),

                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 34,

                          backgroundColor:
                          Color(0xFFE8F7FD),

                          child: Icon(
                            Icons.person,
                            size: 38,
                            color:
                            Color(0xFF00AEEF),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Text(
                                doctor['fullName'] ??
                                    '',

                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,

                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(
                                  height: 6),

                              Text(
                                doctor[
                                'specialtyName'] ??
                                    'Chuyên khoa',

                                style: TextStyle(
                                  color: Colors
                                      .grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {},

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                                0xFF00AEEF),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  14),
                            ),
                          ),

                          child: const Text(
                            'Đặt lịch',

                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickButton(
      IconData icon,
      String title,
      ) {

    return Column(
      children: [

        Container(
          width: 70,
          height: 70,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(22),

            boxShadow: [

              BoxShadow(
                color:
                Colors.black.withOpacity(0.05),

                blurRadius: 10,
              ),
            ],
          ),

          child: Icon(
            icon,
            color: const Color(0xFF00AEEF),
            size: 32,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}