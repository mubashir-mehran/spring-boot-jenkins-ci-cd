package ma.projet.gestionprofesseurs.controllers;

import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.services.SpecialiteService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SpecialiteControllerTest {

    @Mock
    private SpecialiteService specialiteService;

    @InjectMocks
    private SpecialiteController specialiteController;

    private Specialite specialite;

    @BeforeEach
    void setUp() {
        specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);
    }

    @Test
    void testFindAllSpecialite() {
        List<Specialite> specialites = new ArrayList<>();
        specialites.add(specialite);
        when(specialiteService.findAll()).thenReturn(specialites);

        List<Specialite> result = specialiteController.findAllSpecialite();

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(specialiteService, times(1)).findAll();
    }

    @Test
    void testFindById() {
        when(specialiteService.findById(1)).thenReturn(specialite);

        ResponseEntity<Object> response = specialiteController.findById(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(specialiteService, times(1)).findById(1);
    }

    @Test
    void testFindByIdNotFound() {
        when(specialiteService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = specialiteController.findById(999);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("not found"));
        verify(specialiteService, times(1)).findById(999);
    }

    @Test
    void testCreateSpecialite() {
        when(specialiteService.create(any(Specialite.class))).thenReturn(specialite);

        Specialite result = specialiteController.createSpecialite(specialite);

        assertNotNull(result);
        assertEquals(0, specialite.getId()); // Should be set to 0
        verify(specialiteService, times(1)).create(specialite);
    }

    @Test
    void testUpdateSpecialite() {
        when(specialiteService.findById(1)).thenReturn(specialite);
        when(specialiteService.update(any(Specialite.class))).thenReturn(specialite);

        ResponseEntity<Object> response = specialiteController.updateSpecialite(1, specialite);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, specialite.getId()); // Should be set to the path id
        verify(specialiteService, times(1)).findById(1);
        verify(specialiteService, times(1)).update(specialite);
    }

    @Test
    void testUpdateSpecialiteNotFound() {
        when(specialiteService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = specialiteController.updateSpecialite(999, specialite);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("not found"));
        verify(specialiteService, times(1)).findById(999);
        verify(specialiteService, never()).update(any());
    }

    @Test
    void testDeleteSpecialite() {
        when(specialiteService.findById(1)).thenReturn(specialite);
        doNothing().when(specialiteService).delete(specialite);

        ResponseEntity<Object> response = specialiteController.deleteSpecialite(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("deleted"));
        verify(specialiteService, times(1)).findById(1);
        verify(specialiteService, times(1)).delete(specialite);
    }

    @Test
    void testDeleteSpecialiteNotFound() {
        when(specialiteService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = specialiteController.deleteSpecialite(999);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        verify(specialiteService, times(1)).findById(999);
        verify(specialiteService, never()).delete(any());
    }
}


