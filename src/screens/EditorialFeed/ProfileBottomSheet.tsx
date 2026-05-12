import React, { ComponentType } from 'react';
import { View, Modal, TouchableOpacity, Text, StyleSheet } from 'react-native';

type Props = {
  visible: boolean;
  onRequestClose: () => void;
};

export const ProfileBottomSheet: ComponentType<Props> = ({
  visible,
  onRequestClose,
}) => {
  return (
    <Modal
      transparent
      visible={visible}
      onRequestClose={onRequestClose}
      animationType="slide"
    >
      <TouchableOpacity 
        style={styles.overlay} 
        activeOpacity={1}
        onPress={onRequestClose}
      >
        <View style={styles.bottomSheetContent}>
          <TouchableOpacity 
            style={styles.menuItem}
            onPress={() => {}}
          >
            <Text style={styles.menuIcon}>👤</Text>
            <Text style={styles.menuText}>View profile</Text>
            <Text style={styles.menuChevron}>›</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.menuItem}
            onPress={() => {}}
          >
            <Text style={styles.menuIcon}>⚙️</Text>
            <Text style={styles.menuText}>Manage settings</Text>
            <Text style={styles.menuChevron}>›</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  bottomSheetContent: {
    backgroundColor: '#fff',
    paddingBottom: 20,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  menuIcon: {
    fontSize: 20,
    marginRight: 12,
  },
  menuText: {
    flex: 1,
    fontSize: 16,
    color: '#1a1a1a',
  },
  menuChevron: {
    fontSize: 20,
    color: '#999',
  },
});