import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';
import 'package:firebase_storage/firebase_storage.dart';
class CreateUserDatasource {
  Future<Either<IBasExceptions, bool>> createUser(UserEntity newUser) async {
    


try {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    
    final Map<String, dynamic> userMap = newUser.toMap();

      log("Iniciando upload da imagem de perfil para o Storage...");
      
      String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
      
      Reference profileStorageRef = storage.ref().child("users_profiles").child(fileName);
      

      UploadTask uploadTask = profileStorageRef.putData(
        newUser.imageFile!,
        SettableMetadata(contentType: 'image/jpeg'), 
      );
      if(newUser.attacker?.imageFile != null){
        Reference attackerStorageRef = storage.ref().child("attackers_profiles").child(fileName);
        UploadTask attackerUploadTask = attackerStorageRef.putData(
          newUser.attacker!.imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        TaskSnapshot attackerSnapshot = await attackerUploadTask;
        String attackerDownloadUrl = await attackerSnapshot.ref.getDownloadURL();
        log("Upload do atacante concluído! URL da imagem: $attackerDownloadUrl");
        userMap['attacker'] = {
          ...userMap['attacker'],
          'image': attackerDownloadUrl,
          'imageFile': null,
        };
      }
      

      // Aguarda a conclusão do upload
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrlProfile = await snapshot.ref.getDownloadURL();
      log("Upload concluído! URL da imagem: $downloadUrlProfile");

      userMap['image'] = downloadUrlProfile;
      userMap['imageFile'] = null; 
    

    final DocumentReference doc = await firestore.collection("users").add(userMap);
    log('ID NOVO USUÁRIO: ${doc.id}');

    return const Right(true);

    } catch (e) {
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
