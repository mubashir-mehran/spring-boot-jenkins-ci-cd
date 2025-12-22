package ma.projet.gestionprofesseurs.benchmarks;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.ProfesseurRepository;
import ma.projet.gestionprofesseurs.services.ProfesseurService;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;
import org.mockito.Mockito;

import java.util.*;
import java.util.concurrent.TimeUnit;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * JMH Microbenchmark for ProfesseurService methods.
 * Measures performance of CRUD operations and query methods.
 */
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(1)
@State(Scope.Benchmark)
public class ProfesseurServiceBenchmark {
    
    private ProfesseurService professeurService;
    private ProfesseurRepository professeurRepository;
    private Professeur testProfesseur;
    private Specialite testSpecialite;
    private Date dateDebut;
    private Date dateFin;
    
    @Setup(Level.Trial)
    public void setup() {
        // Create mock repository
        professeurRepository = mock(ProfesseurRepository.class);
        
        // Create service with mocked repository
        professeurService = new ProfesseurService();
        // Use reflection to inject the mock (since @Autowired isn't available in JMH)
        try {
            java.lang.reflect.Field field = ProfesseurService.class.getDeclaredField("professeurRepository");
            field.setAccessible(true);
            field.set(professeurService, professeurRepository);
        } catch (Exception e) {
            throw new RuntimeException("Failed to inject mock repository", e);
        }
        
        // Setup test data
        testSpecialite = new Specialite("CS", "Computer Science");
        testSpecialite.setId(1);
        
        testProfesseur = new Professeur();
        testProfesseur.setId(1);
        testProfesseur.setNom("Benchmark");
        testProfesseur.setPrenom("Test");
        testProfesseur.setEmail("benchmark@example.com");
        testProfesseur.setTelephone("123456789");
        testProfesseur.setDateEmbauche(new Date());
        testProfesseur.setSpecialite(testSpecialite);
        
        dateDebut = new Date(System.currentTimeMillis() - 365L * 24 * 60 * 60 * 1000);
        dateFin = new Date();
        
        // Setup mock behavior
        when(professeurRepository.save(any(Professeur.class))).thenReturn(testProfesseur);
        when(professeurRepository.findAll()).thenReturn(Arrays.asList(testProfesseur));
        when(professeurRepository.findById(anyInt())).thenReturn(Optional.of(testProfesseur));
        when(professeurRepository.findBySpecialite(any(Specialite.class)))
            .thenReturn(Arrays.asList(testProfesseur));
        when(professeurRepository.findByDateEmbaucheBetween(any(Date.class), any(Date.class)))
            .thenReturn(Arrays.asList(testProfesseur));
        doNothing().when(professeurRepository).delete(any(Professeur.class));
    }
    
    /**
     * Benchmark for create operation
     */
    @Benchmark
    public Professeur benchmarkCreate() {
        Professeur newProfesseur = new Professeur();
        newProfesseur.setNom("Test");
        newProfesseur.setPrenom("User");
        newProfesseur.setEmail("test@example.com");
        newProfesseur.setTelephone("987654321");
        newProfesseur.setDateEmbauche(new Date());
        newProfesseur.setSpecialite(testSpecialite);
        return professeurService.create(newProfesseur);
    }
    
    /**
     * Benchmark for findAll operation
     */
    @Benchmark
    public List<Professeur> benchmarkFindAll() {
        return professeurService.findAll();
    }
    
    /**
     * Benchmark for findById operation
     */
    @Benchmark
    public Professeur benchmarkFindById() {
        return professeurService.findById(1);
    }
    
    /**
     * Benchmark for update operation
     */
    @Benchmark
    public Professeur benchmarkUpdate() {
        Professeur updateProf = new Professeur();
        updateProf.setId(1);
        updateProf.setNom("Updated");
        updateProf.setPrenom("Name");
        updateProf.setEmail("updated@example.com");
        updateProf.setTelephone("999999999");
        updateProf.setDateEmbauche(new Date());
        updateProf.setSpecialite(testSpecialite);
        return professeurService.update(updateProf);
    }
    
    /**
     * Benchmark for delete operation
     */
    @Benchmark
    public boolean benchmarkDelete() {
        return professeurService.delete(testProfesseur);
    }
    
    /**
     * Benchmark for findBySpecialite operation
     */
    @Benchmark
    public List<Professeur> benchmarkFindBySpecialite() {
        return professeurService.findBySpecialite(testSpecialite);
    }
    
    /**
     * Benchmark for findByDateEmbaucheBetween operation
     */
    @Benchmark
    public List<Professeur> benchmarkFindByDateEmbaucheBetween() {
        return professeurService.findByDateEmbaucheBetween(dateDebut, dateFin);
    }
    
    /**
     * Main method to run benchmarks
     */
    public static void main(String[] args) throws RunnerException {
        Options opt = new OptionsBuilder()
                .include(ProfesseurServiceBenchmark.class.getSimpleName())
                .result("target/jmh-results/professeur-service-results.txt")
                .resultFormat(org.openjdk.jmh.results.format.ResultFormatType.TEXT)
                .build();
        
        new Runner(opt).run();
    }
}
