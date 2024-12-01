import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_management_system/Screen/bottom.dart';
import 'package:store_management_system/Screen/qr.dart';
import 'package:store_management_system/Screen/singup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  Future<void> login() async {
    final String id = _idController.text.trim();
    final String pwd = _pwdController.text.trim();
    print('${id},${pwd},${_idController},${_pwdController}');

    if (id.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID와 비밀번호를 입력하세요.')),
      );
      return;
    }

    try {
      // Step 1: Login 컬렉션에서 ID에 해당하는 문서 가져오기
      DocumentSnapshot userDoc =
          await _firestore.collection('login').doc(id).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('존재하지 않는 ID입니다.')),
        );
        return;
      }

      // 비밀번호 확인
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userData['pwd'] != pwd) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 틀렸습니다.')),
        );
        return;
      }

      // 로그인 성공 후 다음 화면으로 이동
      if (userData['position'] == '사장님') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userDoc : userDoc)),
        );
      } else if (userData['position']=='알바생'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QrScreen(userDoc : userDoc)),
        );
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류 발생')),
      );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 250, // 원하는 너비로 설정
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(labelText: 'ID'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _pwdController,
                      decoration: InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                    ),
                  ])),
          SizedBox(height: 35),
          Container(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                login();
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => HomeScreen()));
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Text(
                '로그인',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 231, 109, 109),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
            ),
          ),
          SizedBox(height: 10), // 버튼과 간격 조정
          Container(
            width: 280,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    // 아이디/비밀번호 찾기 화면으로 이동
                  },
                  child: Text(
                    '아이디/비밀번호 찾기',
                    style: TextStyle(
                        color: const Color.fromARGB(
                            255, 175, 174, 174)), // 원하는 색상으로 설정
                  ),
                ),
                //SizedBox(width: 20,),
                TextButton(
                  onPressed: () {
                    // 회원가입 화면으로 이동
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.blue), // 원하는 색상으로 설정
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
