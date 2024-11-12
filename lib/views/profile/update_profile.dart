part of 'profile_import.dart';


class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  FilePickerResult? _filePickerResult;
  late String? imageId = "";
  late String? userId = "";
  final _nameKey = GlobalKey<FormState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;

      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!);
      imageId =
          Provider.of<UserDataProvider>(context, listen: false).getUserProfile;
    });

    super.initState();
  }

  //open file picker
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    setState(() {
      _filePickerResult = result;
    });
  }

  //upload user image to bucket
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileBytes = await File(file.path!).readAsBytes();
        final inputFile =
            InputFile.fromBytes(bytes: fileBytes, filename: file.name);

        // check images already exist for user or not
        if (imageId != null && imageId != "") {
          await updateImageOnBucket(oldImageId: imageId!, image: inputFile)
              .then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        } else {
          await saveImageToBucket(image: inputFile).then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }
      } else {
        print("something went wrong while uploading image");
      }
    } catch (e) {
      print("error on loading image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dataPassed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        _nameController.text = value.getUserName;
        _phoneController.text = value.getUserPhone;
        return Scaffold(
          appBar: AppBar(
            title:
                Text(dataPassed["title"] == "add" ? "Update" : "Add Details"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      _openFilePicker();
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (_filePickerResult != null &&
                                  _filePickerResult!.files.first.path != null)
                              ? FileImage(
                                  File(_filePickerResult!.files.first.path!))
                              : value.getUserProfile != "" &&
                                      value.getUserProfile != null
                                  ? CachedNetworkImageProvider(
                                      "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${value.getUserProfile}/view?project=672ae4ec00014c5b3400&mode=admin")
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.all(6),
                    child: Form(
                      key: _nameKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "name cannot be empty";
                          } else {
                            return null;
                          }
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name",
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.all(6),
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone Number",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: kBackgroundColor,
                            backgroundColor: kPrimaryColor),
                        onPressed: () async {
                          if (_nameKey.currentState!.validate()) {
                            if (_filePickerResult != null) {
                              await uploadProfileImage();
                            }
                            await updateUserDetails(imageId ?? "",
                                userId: userId ?? "",
                                name: _nameController.text);
                          }
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (route) => false);
                        },
                        child: Text(dataPassed["title"] == "add"
                            ? "Continue"
                            : "Update")),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
