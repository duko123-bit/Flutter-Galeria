import 'package:flutter/material.dart';
import 'dart:async';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  final List<String> _categories = ['Todas', 'Naturaleza', 'Arquitectura', 'Arte', 'Tecnología'];
  String _selectedCategory = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _showSnackBar(_isDarkMode ? 'Modo oscuro activado' : 'Modo claro activado');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar imágenes'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar por número...',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _searchQuery = '';
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtrar por categoría',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'Todas';
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedCategory = 'Todas';
                  _searchQuery = '';
                  _searchController.clear();
                });
                Navigator.pop(context);
              },
              label: const Text('Limpiar todos los filtros'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetail(BuildContext context, String imageUrl, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black87,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 300,
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[800],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Error al cargar la imagen', 
                                 style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Botones de acción
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareImage(imageUrl),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            // Información de la imagen
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Imagen ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categoría: $_selectedCategory',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareImage(String imageUrl) {
    _showSnackBar('Función de compartir imagen');
  }

  Widget _buildImageCard(String imageUrl, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _isDarkMode ? Colors.grey[800]! : Colors.white,
                _isDarkMode ? Colors.grey[700]! : Color(0xFFE3F2FD),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Imagen principal
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, 
                               color: Colors.grey, size: 40),
                          const SizedBox(height: 8),
                          Text('Error al cargar',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    );
                  },
                ),
                
                // Overlay con número
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Gestor de tap para vista detalle
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showImageDetail(context, imageUrl, index),
                      borderRadius: BorderRadius.circular(16),
                      splashColor: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHome();
      case 1:
        return _buildGallery();
      case 2:
        return _buildSettings();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Column(
      children: [
        // Header con búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          color: _isDarkMode ? Colors.grey[800] : Colors.blue[50],
          child: Column(
            children: [
              // Barra de búsqueda
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[700] : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por número de imagen...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[700] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterOptions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filtros rápidos
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'Todas';
                          });
                        },
                        backgroundColor: _isDarkMode ? Colors.grey[700] : null,
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category 
                              ? Colors.white 
                              : _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Grid de imágenes
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(seconds: 1));
            },
            child: _buildGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildGallery() {
    return _buildGrid();
  }

  Widget _buildGrid() {
    return FutureBuilder<List<String>>(
      future: _fetchImagesFromAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDarkMode ? Colors.blue : Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cargando imágenes...',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, 
                     size: 64, 
                     color: _isDarkMode ? Colors.red[300] : Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar imágenes',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDarkMode ? Colors.white70 : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifica tu conexión a internet',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final images = snapshot.data!;
          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, 
                       size: 64, 
                       color: _isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron imágenes',
                    style: TextStyle(
                      fontSize: 18,
                      color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intenta con otros filtros o términos de búsqueda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white60 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          return GridView.extent(
            maxCrossAxisExtent: 200,
            padding: const EdgeInsets.all(8),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;
              return _buildImageCard(imageUrl, index);
            }).toList(),
          );
        } else {
          return Center(
            child: Text(
              'No hay imágenes disponibles',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.palette, color: Colors.blue),
            title: const Text('Tema de la aplicación'),
            subtitle: Text(_isDarkMode ? 'Modo oscuro' : 'Modo claro'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) => _toggleTheme(),
            ),
            onTap: _toggleTheme,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.filter_list, color: Colors.green),
            title: const Text('Filtros activos'),
            subtitle: Text('Categoría: $_selectedCategory'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFilterOptions,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.info, color: Colors.orange),
            title: const Text('Acerca de'),
            subtitle: const Text('Galería Premium v1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnackBar('Galería Premium v1.0.0'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Calificar aplicación'),
            subtitle: const Text('¡Danos tu opinión!'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnackBar('¡Gracias por tu calificación!'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: _isDarkMode ? Colors.grey[500] : Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Galería',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }

  Future<List<String>> _fetchImagesFromAPI() async {
    try {
      List<String> imageUrls = [];
      
      // Generar URLs de imágenes aleatorias de Picsum
      for (int i = 1; i <= 50; i++) {
        String imageUrl = 'https://picsum.photos/500/500?random=$i&cache=${DateTime.now().millisecondsSinceEpoch}';
        
        // Filtrar según búsqueda por número
        if (_searchQuery.isNotEmpty) {
          if (!i.toString().contains(_searchQuery)) {
            continue;
          }
        }
        
        imageUrls.add(imageUrl);
      }
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      
      return imageUrls;

    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galería Premium',
      theme: _isDarkMode 
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.blue,
              colorScheme: ColorScheme.dark(primary: Colors.blue),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                elevation: 8,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              colorScheme: ColorScheme.light(primary: Colors.blue),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue,
                elevation: 8,
              ),
            ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Galería Premium'),
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.blue,
          foregroundColor: Colors.white,
          elevation: 8,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: _buildBody(),
        drawer: _buildDrawer(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: FloatingActionButton(
          elevation: 8.0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onPressed: () {
            _showSnackBar('¡Bienvenido a la Galería Premium!');
          },
          child: const Icon(Icons.photo_library),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.blue, Colors.lightBlue],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, 
                             size: 40, 
                             color: _isDarkMode ? Colors.grey[800] : Colors.blue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Usuario Galería',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Galería Premium',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerTile(
            title: 'Inicio',
            iconData: Icons.home,
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          _buildDrawerTile(
            title: 'Galería',
            iconData: Icons.photo_library,
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          _buildDrawerTile(
            title: 'Configuración',
            iconData: Icons.settings,
            onTap: () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          _buildDrawerTile(
            title: 'Acerca de',
            iconData: Icons.info,
            onTap: () => _showSnackBar('Galería Premium v1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(iconData, 
                   color: _isDarkMode ? Colors.blue[300] : Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

void main() {
  runApp(const MyApp());
}