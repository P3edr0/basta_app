import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class UpdateUserDatasource {
      final storage = FirebaseStorage.instance;

  Future<Either<IBasExceptions, bool>> call(UserEntity newUser) async {
    
    try {
      final db = FirebaseFirestore.instance;
      final handledUser = newUser.toMap();

      
     
      if(newUser.attacker?.imageFile != null){
 String fileName = "attacker_${DateTime.now().millisecondsSinceEpoch}.jpg";

if(newUser.attacker!.image != null){

try {
       Reference oldImage = storage.refFromURL(newUser.attacker!.image!);
            await oldImage.delete();
} catch (e) {
  log("Erro ao deletar imagem antiga do atacante: $e");
}

        }
        Reference attackerStorageRef = storage.ref().child("attackers_profiles").child(fileName);
        UploadTask attackerUploadTask = attackerStorageRef.putData(
          newUser.attacker!.imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        TaskSnapshot attackerSnapshot = await attackerUploadTask;
        String attackerDownloadUrl = await attackerSnapshot.ref.getDownloadURL();
        log("Upload do atacante concluído! URL da imagem: $attackerDownloadUrl");
        handledUser['attacker'] = {
          ...handledUser['attacker'],
          'image': attackerDownloadUrl,
          'imageFile': null,
        };
      }
      if(newUser.imageFile != null){
 String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
 if(newUser.image != null){
  try {
    Reference oldImage = storage.refFromURL(newUser.image!);
    await oldImage.delete();
  } catch (e) {
    log("Erro ao deletar imagem antiga: $e");
  }

        }
        Reference profileStorageRef = storage.ref().child("users_profiles").child(fileName);
        UploadTask profileUploadTask = profileStorageRef.putData(
          newUser.imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        TaskSnapshot profileSnapshot = await profileUploadTask;
        String profileDownloadUrl = await profileSnapshot.ref.getDownloadURL();
        log("Upload do perfil concluído! URL da imagem: $profileDownloadUrl");
        handledUser['image'] = profileDownloadUrl;
        handledUser['imageFile'] = null;
      }
      


      await db.collection("users").doc(newUser.id).update(handledUser);
      return Right(true);
    } catch (e, stackTrace) {
      log("Erro ao atualizar usuário: $e");
      log("Stack trace: $stackTrace");
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}

    
