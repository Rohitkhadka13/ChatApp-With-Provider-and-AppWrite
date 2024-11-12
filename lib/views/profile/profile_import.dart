import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../controllers/appwrite_controllers.dart';
import '../../controllers/local_saved_data.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_data_provider.dart';

part 'profile.dart';
part 'update_profile.dart';