# Database Implementation - SQLite Integration

## Overview
The voice reminder app now uses SQLite database to persist tasks locally on the device. This ensures that tasks are saved permanently and will be available even after app restarts.

## Architecture

### Database Helper (`lib/database/database_helper.dart`)
- Singleton pattern implementation for database management
- Handles database creation, upgrades, and CRUD operations
- Uses `sqflite` package for SQLite operations

### Database Schema
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  dueDate INTEGER NOT NULL,
  createdAt INTEGER DEFAULT (strftime('%s', 'now') * 1000),
  updatedAt INTEGER DEFAULT (strftime('%s', 'now') * 1000)
);
```

### Task Service (`lib/services/task_service.dart`)
- High-level service layer for task operations
- Provides additional functionality like searching, filtering, and sorting
- Includes utility methods for task management

## Features

### Core Database Operations
- **Create**: Add new tasks to the database
- **Read**: Retrieve all tasks or specific tasks
- **Update**: Modify existing task details
- **Delete**: Remove tasks from the database

### Advanced Features
- **Task Filtering**: Get tasks by due date, overdue tasks, upcoming tasks
- **Search**: Search tasks by title or description
- **Export/Import**: JSON-based backup and restore functionality
- **Sorting**: Sort tasks by due date automatically

### State Management Integration
- **TaskBloc Updates**: Modified to use database operations instead of in-memory storage
- **Loading States**: Added loading and error states for async database operations
- **Auto-reload**: Tasks are automatically reloaded from database after modifications

## Usage

### Initialization
The database is automatically initialized when the app starts:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final taskService = TaskService();
  await taskService.initializeDatabase();
  
  runApp(MyApp());
}
```

### TaskBloc Integration
The TaskBloc now performs all operations through the database:
- Loading tasks from database on app start
- Saving new tasks to database
- Updating existing tasks in database
- Deleting tasks from database

### Error Handling
- Database connection errors are handled gracefully
- Loading states are shown during database operations
- Error states display retry options for failed operations

## Database Location
- **Android**: `/data/data/<package_name>/databases/tasks.db`
- **iOS**: Application Documents Directory
- **Desktop**: Platform-specific app data directory

## Migration Support
The database helper includes support for schema migrations:
- Version management for database upgrades
- Backward compatibility for existing installations

## Dependencies
- `sqflite: ^2.4.1` - SQLite plugin for Flutter
- `path: ^1.9.1` - Path manipulation utilities

## Benefits
1. **Persistence**: Tasks survive app restarts and device reboots
2. **Performance**: Local database provides fast read/write operations
3. **Reliability**: SQLite is a proven, stable database solution
4. **Scalability**: Can handle thousands of tasks efficiently
5. **Offline Support**: Works completely offline without internet dependency

## Future Enhancements
- Add task completion status
- Implement task categories/tags
- Add task priority levels
- Implement task reminders/notifications
- Add data synchronization with cloud services
