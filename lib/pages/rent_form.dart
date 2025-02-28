import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RentForm extends StatefulWidget {
  const RentForm({super.key});

  @override
  RentFormState createState() => RentFormState();
}

class RentFormState extends State<RentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController bhkOtherController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController rentController =
      TextEditingController(); // Rent controller

  File? _propertyImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedPropertyType;
  String? _selectedFurnishType;
  String? _selectedBHK;

  @override
  void dispose() {
    nameController.dispose();
    areaController.dispose();
    bhkOtherController.dispose();
    cityController.dispose();
    localityController.dispose();
    rentController.dispose(); // Dispose Rent controller
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _propertyImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_propertyImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('rental_images')
            .child('${DateTime.now()}.jpg');
        await storageRef.putFile(_propertyImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Add rental details to Firestore
      await FirebaseFirestore.instance.collection('rentals').add({
        'name': nameController.text,
        'propertyType': _selectedPropertyType,
        'bhk':
            _selectedBHK == '>3 BHK' ? bhkOtherController.text : _selectedBHK,
        'area': areaController.text,
        'furnishType': _selectedFurnishType,
        'city': cityController.text,
        'locality': localityController.text,
        'rent': rentController.text, // Rent field
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental details added successfully')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, 'Your Name'),
              _buildDropdown(
                label: 'Property Type',
                value: _selectedPropertyType,
                items: ['House', 'Villa', 'Apartment'],
                onChanged: (value) =>
                    setState(() => _selectedPropertyType = value),
              ),
              _buildDropdown(
                label: 'BHK',
                value: _selectedBHK,
                items: ['1 BHK', '2 BHK', '3 BHK', '>3 BHK'],
                onChanged: (value) => setState(() => _selectedBHK = value),
              ),
              if (_selectedBHK == '>3 BHK')
                _buildTextField(bhkOtherController, 'Specify BHK'),
              _buildTextField(areaController, 'Built Up Area (in Sq. ft)'),
              _buildDropdown(
                label: 'Furnish Type',
                value: _selectedFurnishType,
                items: ['Unfurnished', 'Semi-Furnished', 'Fully Furnished'],
                onChanged: (value) =>
                    setState(() => _selectedFurnishType = value),
              ),
              _buildTextField(cityController, 'City'),
              _buildTextField(localityController, 'Locality'),
              _buildTextField(rentController, 'Rent'), // Rent TextField
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text(
                    'Select Property Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                ),
              ),
              if (_propertyImage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _propertyImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Select $label' : null,
      ),
    );
  }
}
